import logo from "./logo.svg";
import "./App.css";
import Library from "./Library";
import Lending from "./Lending";
import Book from "./Book";
import {BrowserRouter, Route, Routes, NavLink} from "react-router-dom";

function App() {
	return (
		<BrowserRouter>
			<div className="App container">
				<h3 className="d-flex justify-content-center m-3"> LibraryCRUD</h3>

				<nav className="navbar navbar-expand-sm bg-light navbar-dark">
					<ul className="navbar-nav">
						<li className="nav-item- m-1">
							<NavLink
								className="btn btn-light btn-outline-primary"
								to="/Libraries">
								Libraries
							</NavLink>
						</li>
						<li className="nav-item- m-1">
							<NavLink
								className="btn btn-light btn-outline-primary"
								to="/Books">
								Books
							</NavLink>
						</li>
						<li className="nav-item- m-1">
							<NavLink
								className="btn btn-light btn-outline-primary"
								to="/Lendings">
								Lendings
							</NavLink>
						</li>
					</ul>
				</nav>
				<Routes>
					<Route path="/Libraries" element={<Library />}></Route>
					<Route path="/Books" element={<Book/>}></Route>
					<Route path="/Lendings" element={<Lending/>}></Route>
				</Routes>
			</div>
		</BrowserRouter>
	);
}

export default App;
