//
//
//  Workspace: GIFGenerator
//  MacOS Version: 11.4
//			
//  File Name: GIFGeneratorTestViewController.swift
//  Creation: 5/31/21 10:11 PM
//
//  Author: Dragos-Costin Mandu
//
//


import UIKit
import GIFGenerator

class GIFGeneratorTestViewController: UIViewController
{
    private var m_GIFGenerator: GIFGenerator!
    private let m_GIFVIew: UIImageView = .init()
    private let m_ExternalGifUrl: URL = .init(string: "https://media.giphy.com/media/NEvPzZ8bd1V4Y/giphy.gif")!
    
    init()
    {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        m_GIFGenerator = GIFGenerator(generatorCompletionHandler: generatorCompletionHandler)
        
        m_GIFVIew.translatesAutoresizingMaskIntoConstraints = false
        m_GIFVIew.contentMode = .scaleAspectFit
        
        view.addSubview(m_GIFVIew)
        
        NSLayoutConstraint.activate(
            [
                m_GIFVIew.widthAnchor.constraint(equalTo: view.widthAnchor),
                m_GIFVIew.heightAnchor.constraint(equalTo: view.heightAnchor)
            ]
        )
        
        m_GIFGenerator.generateWith(url: m_ExternalGifUrl)
    }
    
    func generatorCompletionHandler(_ animatedImage: UIImage?)
    {
        DispatchQueue.main.async
        {
            self.m_GIFVIew.image = animatedImage
        }
    }
}

