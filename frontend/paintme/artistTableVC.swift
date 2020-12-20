//
//  artistTableVC.swift
//  paintme
//
//  Created by Megan Worrel on 12/18/20.
//

import UIKit

class artistTableVC: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchbar: UISearchBar!
    weak var artistDelegate : ArtistReturnDelegate?
    var artists: [String] = ["Vincent Van Gogh", "Another Guy"]
    //var filteredArtists: [String] = ["Vincent Van Gogh", "Another Guy"]
    var inputText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchbar.delegate = self
        self.searchbar.becomeFirstResponder()
        
        let presenter = self.presentingViewController as? paintingTableVC
        
        
        
        view.alpha = 0.85
        
        sortResults()
        
        presenter?.searchbar.text = ""

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.artists.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as! artistCell
        
        cell.name.text = self.artists[indexPath.row]

        // Configure the cell...

        return cell
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sortResults()
    }
    
    func sortResults() {
        self.artists = self.artists.sorted(by: artistSorter)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func artistSorter(artist1: String, artist2: String) -> Bool {
        let artist1 = artist1.lowercased()
        let artist2 = artist2.lowercased()
        let search = self.searchbar.text?.lowercased() ?? ""
        
        var artist1count = 0
        var artist2count = 0
        if artist1.contains(search) {
            artist1count += 1
        }
        if artist2.contains(search) {
            artist2count += 1
        }
        if artist1.prefix(search.count) == search {
            artist1count += 1
        }
        if artist2.prefix(search.count) == search {
            artist2count += 1
        }
        
        if artist1count > artist2count{
            return true
        } else if artist2count > artist1count {
            return false
        } else {
            return artist1 < artist2
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.artistDelegate?.didReturnArtist(self.artists[indexPath.row])
        self.dismiss(animated: false, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// Generic return result delegate protocol
protocol ArtistReturnDelegate: UIViewController {
    func didReturnArtist(_ artist: String)
}
