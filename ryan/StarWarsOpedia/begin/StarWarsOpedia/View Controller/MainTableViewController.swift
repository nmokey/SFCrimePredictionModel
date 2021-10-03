import UIKit
import Alamofire

class MainTableViewController: UITableViewController {
  var films: [Film] = []
  var items: [Displayable] = []
  var selectedItem: Displayable? //You’ll store the currently-selected film to this property.

  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBar.delegate = self
    fetchFilms() //This triggers the Alamofire request.
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count //This ensures that you show as many cells as there are films.
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "dataCell", for: indexPath)
    let item = items[indexPath.row] //set up the cell with the film name and episode ID, using the properties provided via Displayable.
    cell.textLabel?.text = item.titleLabelText
    cell.detailTextLabel?.text = item.subtitleLabelText
    return cell
  }
  
  override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
    selectedItem = items[indexPath.row] //Here, you’re taking the film from the selected row and saving it to selectedItem.
    return indexPath

  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let destinationVC = segue.destination as? DetailViewController else {
      return
    }
    destinationVC.data = selectedItem //This sets the user’s selection as the data to display.
  }
}

// MARK: - UISearchBarDelegate
extension MainTableViewController: UISearchBarDelegate {
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    guard let shipName = searchBar.text else { return }
    searchStarships(for: shipName)
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.text = nil
    searchBar.resignFirstResponder() //hides keyboard
    items = films
    tableView.reloadData()
  }
}

extension MainTableViewController {
  func fetchFilms() {
    //  Alamofire uses namespacing, so you need to prefix all calls that you use with AF. request(_:method:parameters:encoding:headers:interceptor:) accepts the endpoint for your data. It can accept more parameters, but for now, you’ll just send the URL as a string and use the default parameter values.
    AF.request("https://swapi.dev/api/films")
      .validate()
      .responseDecodable(of: Films.self) { (response) in
        guard let films = response.value else { return }
        self.films = films.all //This saves away the list for films for easy access later.
        self.items = films.all //This assigns all retrieved films to items and
        self.tableView.reloadData() //reloads the table view.
      }
  }
  func searchStarships(for name: String) {
    // 1 - Sets the URL that you’ll use to access the starship data.
    let url = "https://swapi.dev/api/starships"
    // 2 - Sets the key-value parameters that you’ll send to the endpoint.
    let parameters: [String: String] = ["search": name]
    // 3 - Here, you’re making a request like before, but this time you’ve added parameters.
    AF.request(url, parameters: parameters)
      .validate()
      .responseDecodable(of: Starships.self) { response in
        // 4 - you assign the list of starships as the table view’s data and reload the table view
        guard let starships = response.value else { return }
        self.items = starships.all
        self.tableView.reloadData()
    }
  }

}
