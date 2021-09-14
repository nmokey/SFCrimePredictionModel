import UIKit
import Alamofire

class MainTableViewController: UITableViewController {
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    fetchFilms() //This triggers the Alamofire request.
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    return indexPath
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let destinationVC = segue.destination as? DetailViewController else {
      return
    }
    destinationVC.data = nil
  }
}

// MARK: - UISearchBarDelegate
extension MainTableViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
  }
}

extension MainTableViewController {
  func fetchFilms() {
    // 1 - Alamofire uses namespacing, so you need to prefix all calls that you use with AF. request(_:method:parameters:encoding:headers:interceptor:) accepts the endpoint for your data. It can accept more parameters, but for now, you’ll just send the URL as a string and use the default parameter values.
    let request = AF.request("https://swapi.dev/api/films")
    
    // 2 - Take the response given from the request as JSON. For now, you simply print the JSON data for debugging purposes.
    request.responseJSON { (data) in
      print(data)
    }
  }
}
