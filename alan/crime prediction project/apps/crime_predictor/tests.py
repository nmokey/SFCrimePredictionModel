from django.test import TestCase, Client
from models import CrimePredictionLog

# Create your tests here.
class CrimePredictionTest(TestCase):
	def test_GETRequest(self):
		res = self.client.get('/crime/predict')
		self.assertEqual(res.status_code, 200)

class CrimePredictionDatabaseLogsTest(TestCase):
	def test_save_log(self):
		dummyLog = CrimePredictionLog()
		dummyLog.save()
		self.assertTrue(CrimePredictionLog.objects.filter().exists())