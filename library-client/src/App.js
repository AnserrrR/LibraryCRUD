import "./App.css";
import Library from "./Library";
import Lending from "./Lending";
import Book from "./Book";
import Analitics from "./Analitics";
import { Dropdown } from "react-bootstrap";
import {BrowserRouter, Route, Routes, NavLink} from "react-router-dom";

function App() {
	return (
		<BrowserRouter>
			<div className="App container">
				<h3 className="d-flex justify-content-center m-3">LibraryCRUD</h3>

				<nav className="navbar navbar-expand-sm bg-light navbar-dark rounded">
					<ul className="navbar-nav">
						<li className="nav-item m-1">
							<NavLink className="btn btn-secondary" to="/Libraries">
								Libraries
							</NavLink>
						</li>
						<li className="nav-item- m-1">
							<NavLink className="btn btn-secondary" to="/Books">
								Books
							</NavLink>
						</li>
						<li className="nav-item- m-1">
							<NavLink className="btn btn-secondary" to="/Lendings">
								Lendings
							</NavLink>
						</li>
						<div className="vr"></div>
						<li className="nav-item- m-1">
							<Dropdown>
								<Dropdown.Toggle variant="secondary" id="dropdown-basic">
									Dropdown Button
								</Dropdown.Toggle>

								<Dropdown.Menu>
									<Dropdown.Item href="/Analitic/action-1">
										Action
									</Dropdown.Item>
									<Dropdown.Item href="/Analitic/action-1">
										Another action
									</Dropdown.Item>
									<Dropdown.Item href="/Analitic/action-1">
										Something else
									</Dropdown.Item>
								</Dropdown.Menu>
							</Dropdown>
						</li>
					</ul>
				</nav>
				<Routes>
					<Route path="/Libraries" element={<Library />}></Route>
					<Route path="/Books" element={<Book />}></Route>
					<Route path="/Lendings" element={<Lending />}></Route>
					<Route path="/Analitic/action-1" element={<Analitics />}></Route>
				</Routes>
			</div>
		</BrowserRouter>
	);
}

export default App;
