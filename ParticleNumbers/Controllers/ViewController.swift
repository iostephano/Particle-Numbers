//
//  ViewController.swift
//  ParticleNumbers
//
//  Created by Stephano Portella on 04/06/25.
//

import UIKit

final class ViewController: UIViewController {

    private let particleView = ParticleMetalView(frame: .zero)

    private let generateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Generar número", for: .normal)
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
        let number = Int.random(in: 0...99)
        particleView.animateParticles(to: "\(number)")
    }
}
