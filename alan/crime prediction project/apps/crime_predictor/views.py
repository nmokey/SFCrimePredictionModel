from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
import numpy as np
from .models import CrimePredictionLog
import json
import pickle
from django.utils import timezone, dateparse
import pandas as pd
from sklearn.preprocessing import LabelEncoder 
# from django.views.decorators.csrf import csrf_exempt
# Create your views here.

# @csrf_exempt

def feature_engineering(data):
    data['Date'] = pd.to_datetime(data['Dates'].dt.date)
    data['n_days'] = (
        data['Date'] - data['Date'].min()).apply(lambda x: x.days)
    data['Day'] = data['Dates'].dt.day
    data['DayOfWeek'] = data['Dates'].dt.weekday
    data['Month'] = data['Dates'].dt.month
    data['Year'] = data['Dates'].dt.year
    data['Hour'] = data['Dates'].dt.hour
    data['Minute'] = data['Dates'].dt.minute
    data['Block'] = data['Address'].str.contains('block', case=False)
    
    data.drop(columns=['Dates','Date','Address'], inplace=True)
        
    return data

def checkInputs(X):
	features = ['Dates', 'PdDistrict', 'Longitude', 'Latitude', 'DayOfWeek', 'Address']
	types = [str, str, float, float, str, str]
	DOW_CHOICES = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY']
	PDD_CHOICES = ['TENDERLOIN', 'RICHMOND', 'NORTHERN', 'SOUTHERN', 'CENTRAL', 'BAYVIEW', 'INGLESIDE',
	'MISSION', 'PARK', 'TARAVAL']

	if set(X.keys()) != set(features):
		return False 

	for i, f in enumerate(features):  
		if type(X[f]) != types[i]:
			return False 
	
		if f == 'DayOfWeek' and X[f].strip().upper() not in DOW_CHOICES:
			# print("DOW Error")
			return False 

		if f == 'PdDistrict' and X[f].strip().upper() not in PDD_CHOICES: 
			# print("PdDistrict Error")
			return False 
	
	return True 
	
	

def process_data(X):
	le1 = LabelEncoder()
	le1.classes_ = np.load('./research/LabelEncoders/le1_classes.npy', allow_pickle = True)
	
	X['Dates'] = pd.to_datetime(X['Dates'], errors = 'raise')
	print(X['Dates'])
	
	X = feature_engineering(X)
	X['PdDistrict'] = le1.transform(X['PdDistrict'])
	X.rename(columns = {'Longitude': 'X', 'Latitude': 'Y'}, inplace = True)
	return X


def index(req):
	return HttpResponse('Hello, world. This is a test view.')

def predict_GET(req):
	return HttpResponse('Hello, world. This is a test view.')

def predict_POST(req):
	try: 
		body_unicode = req.body.decode('utf-8')
		body = json.loads(body_unicode)
		print(body)
		body = body['Features']
		assert checkInputs(body)
		X = pd.DataFrame([body])
		X = process_data(X)

	#Error handling for data preprocessing
	except (KeyError, CrimePredictionLog.DoesNotExist):
		return JsonResponse({'Message': 'Prediction not ok :(', 'Result': 'KeyError: Please enter input data'}, 
		safe = False)

	except(AssertionError):
		print("Invalid inputs, make sure inputs are all of the proper type and values.")
		return JsonResponse({'Message': 'Invalid inputs, try again.', 
		'Result': 'Invalid inputs, make sure inptus are all of the proper type and values.'}, safe = False)

	except(pd.errors.ParserError):
		return JsonResponse({'Message': 'ParserError - parser error encountered, prediction input preprocessing failed.', 
		'Result': 'ParserError - prediction input invalid, check if datetime given was a valid datetime string.'}, safe = False)

	except(ValueError):
		return JsonResponse({'Message': 'ValueError - datetime parsing during prediction input preprocessing failed.', 
		'Result': 'ValueError - prediction input invalid, check if datetime given was a valid datetime string.'}, safe = False)

	else:
		model = pickle.load(open('./research/models/model', 'rb'))
		
		try:
			new_log = CrimePredictionLog(
				Date = timezone.make_aware(dateparse.parse_datetime(body['Dates'])),
				Latitude = body['Latitude'],
				Longitude = body['Longitude'],
				PdDistrict = body['PdDistrict'].upper(),
				DayOfWeek = body['DayOfWeek'].upper()
			)
		except(ValueError) as ve:
			print(ve)
		# print(new_log.DayOfWeek)
		# print(new_log.PdDistrict)
		new_log.save()

		le2 = LabelEncoder()
		le2.classes_ = np.load('./research/LabelEncoders/le2_classes.npy', allow_pickle = True)
		y_pred = model.predict(X)

		result = pd.Series(data = y_pred[0], 
			index = le2.inverse_transform(np.linspace(0, 38, 39, dtype = 'int16'))).to_dict()

		parsed_result = []
		for crime, prob in result.items():
			parsed_result.append({'Crime': crime, 'Prob': prob})

		print(parsed_result)
		return JsonResponse({'Message': 'Prediction ok!', 'Result': parsed_result}, safe = False)

def predict(req):
	TYPE = req.method
	
	if TYPE == 'POST':
		return predict_POST(req)
	elif TYPE == 'GET':
		return predict_GET(req)