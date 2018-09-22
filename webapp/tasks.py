from __future__ import absolute_import, unicode_literals
from django.contrib.auth.models import User
from django.utils.crypto import get_random_string

import json

from celery import shared_task

WORDS = ['han', 'hon', 'den', 'det', 'denna', 'denne', 'hen']

@shared_task(task_track_started = True)
def count_file(file_path):
	print(file_path)
	word_count = dict(zip(WORDS, [0] * len(WORDS)))
	tweet_file = open(file_path)

	tweets = (line.rstrip() for line in tweet_file)
	tweets_json = (json.loads(line) for line in tweets if line)

	for tweet in tweets_json:
			tweet_txt = tweet['text']
			tweet_txt = tweet_txt.lower()

			for key in word_count.keys():
				if key in tweet_txt:
					word_count[key] += 1

	return word_count
