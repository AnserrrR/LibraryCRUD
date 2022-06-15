import React, {useEffect, useState} from "react";
import BookTable from "./AnaliticsTables/BookTable.js";
import StaffTable from "./AnaliticsTables/StaffTable.js";
import ReaderTable from "./AnaliticsTables/ReaderTable.js";
import {variables} from "./variables.js";
import {BrowserRouter, Route, Routes, NavLink} from "react-router-dom";

function Analitics(props) {
	const [AnaliticsData, setData] = useState([]);

	useEffect(() => {
		refreshList();
	}, []);

	async function refreshList() {
		fetch(variables.API_URL + `Analitics/${props.query}`)
			.then(response => response.json())
			.then(data => {
				setData(data);
			});
	}

	//Render
	return (
		<div>
			<h3>Top {props.query}:</h3>
			{props.query == "Staff" ? (
				<StaffTable data={AnaliticsData}></StaffTable>
			) : null}
			{props.query == "Books" ? (
				<BookTable data={AnaliticsData}></BookTable>
			) : null}
			{props.query == "Readers" ? (
				<ReaderTable data={AnaliticsData}></ReaderTable>
			) : null}
		</div>
	);
}

export default Analitics;
