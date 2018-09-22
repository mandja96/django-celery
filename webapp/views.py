# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from os import listdir
from os.path import isfile, join

import numpy as np

import time

import json

from django.shortcuts import render
from django.http import HttpResponse

from celery.result import AsyncResult
from webapp.tasks import count_file

from webapp.forms import GenerateForm

# Create your views here.

WORDS = ['han', 'hon', 'den', 'det', 'denna', 'denne', 'hen']

def count_tweets(request):
    if request.method == 'POST':
        form = GenerateForm(request.POST)
        if form.is_valid():
            files_number = form.cleaned_data.get('total_file')
            word_count_task = []
            path = "/mnt/tweet_data/tweets" #/mnt/tweet_data/tweets
            file_list = [f for f in listdir(path) if isfile(join(path, f))]
            file_list = np.random.choice(file_list, files_number, replace=False)
            for file in file_list:
                file_path = path + '/' + file
                task = count_file.delay(file_path)
                time.sleep(0.02)
                word_count_task.append(task.id)
                print("Task submitted!")
            return HttpResponse(json.dumps({'task_id': word_count_task}), content_type='application/json')
        else:
            return HttpResponse(json.dumps({'task_id': None}), content_type='application/json')
    else:
        form = GenerateForm

    return render(request, './webapp/index.html', {'form': form})

def get_task_info(request):
    task_id = request.GET.getlist('task_id[]', None)

    states = []
    results = []
    l = len(task_id)
    for i in range(l):
        if task_id[i] is not None:
            task = AsyncResult(task_id[i])
            states.append(task.state)
            results.append(task.result)
        else:
          return HttpResponse('No job ID given.')

    data = {'state': states, 'result': results,}

    return HttpResponse(json.dumps(data), content_type='application/json')
