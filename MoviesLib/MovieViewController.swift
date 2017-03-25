//
//  ViewController.swift
//  MoviesLib
//
//  Created by Eric on 06/03/17.
//  Copyright © 2017 EricBrito. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class MovieViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbGenre: UILabel!
    @IBOutlet weak var lbDuration: UILabel!
    @IBOutlet weak var lbScore: UILabel!
    @IBOutlet weak var tvSinopsis: UITextView!
    @IBOutlet weak var lcButtonX: NSLayoutConstraint!
    @IBOutlet weak var viTrailer: UIView!
    
    // MARK: Properties
    var movie: Movie!
    
    var moviePlayer: AVPlayer!
    var moviePlayerController: AVPlayerViewController!
    
    
    // MARK: Super Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareVideo()
        
        if UserDefaults.standard.bool(forKey: SettingsType.autoplay.rawValue){
            
            changeMovieStatus(play:true)
        }else{
            
            // animacao
            let oldHeight = ivPoster.frame.size.height
            ivPoster.frame.size.height = 0
            UIView.animate(withDuration: 0.75, delay: 0, options: .curveEaseInOut, animations: { 
                // a animacao acontece aqui. o estado final da animacao
                self.ivPoster.frame.size.height = oldHeight
            }, completion: { (sucess: Bool) in
                print("fim da animacao")
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //ivPoster.image = UIImage(named: movie.imageWide)
        lbTitle.text = movie.title
        lbDuration.text = movie.duration
        lbScore.text = "⭐️ \(movie.rating)/10"
        if let categories = movie.categories {
            lbGenre.text = categories.map({($0 as! Category).name!}).joined(separator: " | ")
        }
        if let image = movie.poster as? UIImage {
            ivPoster.image = image
        }
        tvSinopsis.text = movie.summary
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MovieRegisterViewController {
            vc.movie = movie
        }
    }
    
    
    func prepareVideo(){
        
        //let url = Bundle.main.url(forResource: "logan-trailer.mp4", withExtension: nil)!
        let url = URL(string: "http:/goo.gl/8XmNn8")!
        moviePlayer = AVPlayer(url: url)
        moviePlayerController = AVPlayerViewController();
        moviePlayerController.player = moviePlayer
        // dessa forma agente ve o controles no video
        moviePlayerController.showsPlaybackControls = true
        moviePlayerController.view.frame = viTrailer.bounds
        viTrailer.addSubview(moviePlayerController.view)
 
    
    }
    
    
    @IBAction func playVideo(_ sender: UIButton) {
        sender.isHidden = false
        changeMovieStatus(play: true)
    }
    
    func changeMovieStatus(play: Bool){
        
        viTrailer.isHidden = false
        if play{
            moviePlayer.play()
        }else{
            moviePlayer.pause()
        }
        
    }
    
}
