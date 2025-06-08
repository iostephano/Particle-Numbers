//
//  ViewController.swift
//  Particle Numbers
//
//  Created by Stephano Portella on 04/06/25.
//

import UIKit

class ViewController: UIViewController {

    private var particleView: ParticleMetalView!
    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generate Number", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        button.layer.cornerRadius = 12
        button.setTitleColor(.white, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupParticleView()
        setupButton()
    }

    private func setupParticleView() {
        // Instancia ParticleMetalView cubriendo toda la pantalla
        particleView = ParticleMetalView(frame: view.bounds)
        particleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(particleView)

        NSLayoutConstraint.activate([
            particleView.topAnchor.constraint(equalTo: view.topAnchor),
            particleView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            particleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            particleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func setupButton() {
        // Coloca el botón en la parte inferior, centrado
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(generateButton)
        generateButton.addTarget(self, action: #selector(generateNumber), for: .touchUpInside)

        NSLayoutConstraint.activate([
            generateButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            generateButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            generateButton.widthAnchor.constraint(equalToConstant: 180),
            generateButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func generateNumber() {
        // Genera un número aleatorio entre 0 y 99 y lanza la animación
        let number = Int.random(in: 0...99)
        particleView.animateParticles(to: "\(number)")
    }
}
