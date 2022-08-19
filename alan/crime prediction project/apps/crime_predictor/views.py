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

def process_data(X):
	le1 = LabelEncoder()
	le1.classes_ = np.load('./research/LabelEncoders/le1_classes.npy', allow_pickle = True)
	
	X['Dates'] = pd.to_datetime(X['Dates'])
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
		body = json.loads(body_unicode)['Features']
		X = pd.DataFrame([body])
		X = process_data(X)
		# print(X)

	except (KeyError, CrimePredictionLog.DoesNotExist):
		return JsonResponse({'Message': 'Prediction not ok :(', 'Result': 'KeyError: Please enter input data'}, 
		safe = False)

	else:
		model = pickle.load(open('./research/models/model', 'rb'))
		
		new_log = CrimePredictionLog(
			Date = timezone.make_aware(dateparse.parse_datetime(body['Dates'])),
			Latitude = body['Latitude'],
			Longitude = body['Longitude'],
			PdDistrict = body['PdDistrict'],
			DayOfWeek = body['DayOfWeek'].upper()
		)
		# print(new_log.DayOfWeek)
		# print(new_log.PdDistrict)
		new_log.save()

		le2 = LabelEncoder()
		le2.classes_ = np.load('./research/LabelEncoders/le2_classes.npy', allow_pickle = True)
		y_pred = model.predict(X)

		result = pd.Series(data = y_pred[0], 
			index = le2.inverse_transform(np.linspace(0, 38, 39, dtype = 'int16'))).to_dict()

		return JsonResponse({'Message': 'Prediction ok!', 'Result': result}, safe = False)

def predict(req):
	TYPE = req.method
	
	if TYPE == 'POST':
		return predict_POST(req)
	elif TYPE == 'GET':
		return predict_GET(req)