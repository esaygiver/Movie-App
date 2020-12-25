//
//  ViewController.swift
//  Esay - Movie App
//
//  Created by admin on 16.12.2020.
//  Copyright © 2020 esaygiver. All rights reserved.
//

import UIKit
import SafariServices

// UI
// Network Request
// tap a cell to see info about the movie
// custom cell

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var textField: UITextField!
    
    var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(MovieTableViewCell.nib(), forCellReuseIdentifier: MovieTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        textField.delegate = self
    }
    // new api = "https://www.omdbapi.com/?i=(imdbId)&apikey=f758601e"
    // old api ="https://www.omdbapi.com/?apikey=f758601e=fast%20and&type=movie"
    
//MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
        cell.configure(with: movies[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Show movie details
        let id = movies[indexPath.row].imdbID
        let url = "https://www.imdb.com/title/\(id)/"
        let vc = SFSafariViewController(url: URL(string: url)!)
        present(vc, animated: true)
        
    }
 
//MARK: - UITextField Delegate
    
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        textField.endEditing(true)
    }
 
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchMovies()
        textField.endEditing(true)
        return true
}
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }

    
func searchMovies() {
    textField.resignFirstResponder()
    
    guard let text = textField.text, !text.isEmpty else { return }
    
    let query = text.replacingOccurrences(of: " ", with: "%20")
    movies.removeAll()
    
    // Network Request
    URLSession.shared.dataTask(with: URL(string: "https://www.omdbapi.com/?apikey=3aea79ac&s=\(query)&type=movie")!, completionHandler: { data, resp, error in
                                
        guard let data = data, error == nil else { return }
            
            // Convert
            var result: MovieResult?
            do {
                result = try JSONDecoder().decode(MovieResult.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
                
        guard let finalResult = result else { return }
        print("\(finalResult.Search.first?.Title)")
         
        // update our movies array
        let newMovies = finalResult.Search
        self.movies.append(contentsOf: newMovies)
        
        // Refresh our table
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
        }).resume()
    }
}
