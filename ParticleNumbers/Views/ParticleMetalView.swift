//
//  ParticleMetalView.swift
//  ParticleNumbers
//
//  Created by Stephano Portella on 04/06/25.
//

import MetalKit
import simd

/// Una partícula: posición actual más las posiciones inicial y destino de la
/// fase en curso, para poder interpolar entre ambas. El layout coincide con el
/// `struct Particle` de `ParticleShader.metal`.
struct Particle {
    var position: SIMD2<Float>
    var originalPosition: SIMD2<Float>
    var targetPosition: SIMD2<Float>
    var color: SIMD4<Float>
}

/// Fases del ciclo de animación. Cada `Generar número` reinicia el ciclo en
/// `forming`; al terminar `dispersing` se vuelve a `idle`.
enum AnimationState {
    case idle
    case forming
    case holding
    case dispersing
}

final class ParticleMetalView: MTKView {

    /// Tamaño en puntos de cada partícula al dibujarse. Se pasa al vertex shader.
    var pointSize: Float = 4.0

    // MARK: - Metal

    private let commandQueue: MTLCommandQueue
    private let pipeline: MTLRenderPipelineState

    // MARK: - Partículas

    private var particles: [Particle] = []
    private var particleBuffer: MTLBuffer

    private static let particleCount = 2000

    // MARK: - Animación

    private var state: AnimationState = .idle
    private var frameCount = 0
    private let formationDuration = 60    // frames disperso -> número
    private let holdDuration = 180        // frames sosteniendo el número (~3 s a 60 fps)
    private let dispersingDuration = 60   // frames número -> disperso

    // MARK: - Init

    override init(frame frameRect: CGRect, device: MTLDevice?) {
        let metalDevice = device ?? MTLCreateSystemDefaultDevice()
        guard let metalDevice else {
            fatalError("Metal no está disponible en este dispositivo")
        }
        guard let queue = metalDevice.makeCommandQueue() else {
            fatalError("No se pudo crear el command queue de Metal")
        }
        self.commandQueue = queue
        self.pipeline = Self.makePipeline(device: metalDevice)

        let (initial, buffer) = Self.makeParticles(device: metalDevice)
        self.particles = initial
        self.particleBuffer = buffer

        super.init(frame: frameRect, device: metalDevice)

        colorPixelFormat = .bgra8Unorm
        framebufferOnly = false
        isPaused = false
        preferredFramesPerSecond = 60
    }

    convenience init(frame frameRect: CGRect) {
        self.init(frame: frameRect, device: nil)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) no está implementado")
    }

    // MARK: - Setup

    private static func makePipeline(device: MTLDevice) -> MTLRenderPipelineState {
        guard let library = device.makeDefaultLibrary() else {
            fatalError("No se encontró la librería Metal por defecto (¿falta ParticleShader.metal en el target?)")
        }
        let descriptor = MTLRenderPipelineDescriptor()
        descriptor.vertexFunction = library.makeFunction(name: "vertexShader")
        descriptor.fragmentFunction = library.makeFunction(name: "fragmentShader")
        descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            return try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            fatalError("No se pudo crear el pipeline state: \(error)")
        }
    }

    private static func makeParticles(device: MTLDevice) -> ([Particle], MTLBuffer) {
        let particles = (0..<particleCount).map { _ -> Particle in
            let position = SIMD2<Float>(.random(in: -1...1), .random(in: -1...1))
            let color = SIMD4<Float>(
                .random(in: 0.3...1.0),
                .random(in: 0.3...1.0),
                .random(in: 0.3...1.0),
                1.0
            )
            return Particle(
                position: position,
                originalPosition: position,
                targetPosition: position,
                color: color
            )
        }
        let length = MemoryLayout<Particle>.stride * particles.count
        guard let buffer = device.makeBuffer(bytes: particles, length: length, options: .storageModeShared) else {
            fatalError("No se pudo crear el buffer de partículas")
        }
        return (particles, buffer)
    }

    // MARK: - API pública

    /// Lanza la animación que reagrupa las partículas para formar `numberString`.
    func animateParticles(to numberString: String) {
        let mask = TextParticleMask.points(for: numberString)
        let targets = ParticleTargetFitter.fit(mask, to: particles.count)

        for i in particles.indices {
            particles[i].originalPosition = particles[i].position
            particles[i].targetPosition = targets[i]
        }
        uploadParticles()

        state = .forming
        frameCount = 0
    }

    // MARK: - Loop

    override func draw(_ rect: CGRect) {
        guard let drawable = currentDrawable,
              let descriptor = currentRenderPassDescriptor else {
            return
        }

        if advanceAnimation() {
            uploadParticles()
        }

        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }

        encoder.setRenderPipelineState(pipeline)
        encoder.setVertexBuffer(particleBuffer, offset: 0, index: 0)
        var size = pointSize
        encoder.setVertexBytes(&size, length: MemoryLayout<Float>.size, index: 1)
        encoder.drawPrimitives(type: .point, vertexStart: 0, vertexCount: particles.count)
        encoder.endEncoding()

        commandBuffer.present(drawable)
        commandBuffer.commit()
    }

    /// Avanza un frame de la máquina de estados. Devuelve `true` si movió alguna
    /// partícula (y por lo tanto hay que volver a subir el buffer a la GPU).
    private func advanceAnimation() -> Bool {
        switch state {
        case .idle:
            return false

        case .forming:
            let t = min(Float(frameCount) / Float(formationDuration), 1.0)
            interpolateParticles(t)
            frameCount += 1
            if frameCount >= formationDuration {
                state = .holding
                frameCount = 0
            }
            return true

        case .holding:
            frameCount += 1
            if frameCount >= holdDuration {
                for i in particles.indices {
                    particles[i].originalPosition = particles[i].position
                    particles[i].targetPosition = SIMD2<Float>(.random(in: -1...1), .random(in: -1...1))
                }
                state = .dispersing
                frameCount = 0
            }
            return false

        case .dispersing:
            let t = min(Float(frameCount) / Float(dispersingDuration), 1.0)
            interpolateParticles(t)
            frameCount += 1
            if frameCount >= dispersingDuration {
                for i in particles.indices {
                    particles[i].originalPosition = particles[i].position
                    particles[i].targetPosition = particles[i].position
                }
                state = .idle
                frameCount = 0
            }
            return true
        }
    }

    private func interpolateParticles(_ t: Float) {
        for i in particles.indices {
            particles[i].position = simd_mix(particles[i].originalPosition, particles[i].targetPosition, SIMD2<Float>(repeating: t))
        }
    }

    private func uploadParticles() {
        particles.withUnsafeBytes { raw in
            guard let base = raw.baseAddress else { return }
            particleBuffer.contents().copyMemory(from: base, byteCount: raw.count)
        }
    }
}
