from django.db import models
from datetime import datetime
from django.utils import timezone
from django.utils.translation import gettext_lazy as _

# Create your models here.

class CrimePredictionLog(models.Model):
	DAY_OF_WEEK_CHOICES = [
		('MON', 'MONDAY'),
		('TUE', 'TUESDAY'),
		('WED', 'WEDNESDAY'),
		('THU', 'THURSDAY'),
		('FRI', 'FRIDAY'),
		('SAT', 'SATURDAY'),
		('SUN', 'SUNDAY')
	]

	PD_DISTRICT_CHOICES = [
		('RI', 'RICHMOND'),
		('NO', 'NORTHERN'),
		('CE', 'CENTRAL'),
		('TE', 'TENDERLOIN'),
		('SO', 'SOUTHERN'),
		('BA', 'BAYVIEW'),
		('IN', 'INGLESIDE'),
		('MI', 'MISSION'),
		('PA', 'PARK'), 
		('TA', 'TARAVAL')
	]

	Date = models.DateTimeField(default = timezone.now, blank = True)
	Longitude = models.FloatField(default = 0.0)
	Latitude = models.FloatField(default = 0.0)
	PdDistrict = models.CharField(max_length = 1000, choices = PD_DISTRICT_CHOICES, 
								  default = 'SOUTHERN')
	DayOfWeek = models.CharField(max_length = 1000, choices = DAY_OF_WEEK_CHOICES, default = 'MONDAY')