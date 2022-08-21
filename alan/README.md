## Alan's work on the backend
Using Django - Python framework

/crime/predict - GET:
	Request: GET request with no parameters
	Response: HTML static page

/crime/predict - POST:
	Request: POST request with body (as JSON):

	{
		'Features': {
			'Latitude': float,
			'Longitude': float,
			'Address': string,
			'Dates': string in datetime format, 
			'PdDistrict': string (required to be valid SFPD district),
			'DayOfWeek': string (required to be valid weekday)
		}
	}

	Response:

	{
		'Message': string,
		'Result': {
			'Crime1': prob1,
			'Crime2': prob2,
			...
		}
	}