# SFCrimePredictionModel
iOS app for prediction San Francisco crime rates and probabilities.

## Motivation

Big cities like San Francisco have a lot of street crimes. Different types crimes tend to happen depending on the time of the day and locations. It will be very helpful for people in San Francisco to know in real-time what types of crimes can happen around them.

## Goal

Build a mobile App that can use the user's location and their current time while they are in San Francisco to predict the most likely crimes that could happen close to them.

## Project Phases

1. Build a backend that can give probabilities of different types of crimes in San Francisco, given specific time of the day as well as locations in San Francisco.The prediction model is take from [Kaggle's San Francisco Crime Classification Competition](https://www.kaggle.com/c/sf-crime/code). 

2. Build a mobile App that can extract user's location in San Francisco

3. Integrate the mobile App with the backend such that the mobile App can send time and location to the backend and get back a list of probailities of different types of crimes.

## Screenshots

### Ver 1.0
<img src="https://user-images.githubusercontent.com/756243/202640802-21d0f2c5-07f6-44d7-9e57-858a6e3b5ae4.png" width="200">

## Development

### Start backend locally

Dependencies:

- python 3.9 or above

```
cd SFCrimePredictionModel\alan/crime\ prediction\ project

python3.9 -m venv venv

source venv/bin/activate

pip3.9 install  -r requirements.txt

python3.9 manage.py migrate

python3.9 manage.py runserver
```

### Load xCode project for ios app dev

Load `SFCrimePredictionModel/sfcrimeios` as a xcode project.

# Team members
- Ryan (nmokey)
- Xiang (xxiao23)
- Albus (AimBotSwitch)
- Sahil (sahilmehta-US)
- Alan (switchpiggy)
