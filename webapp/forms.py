from django import forms

class GenerateForm(forms.Form):
    total_file = forms.IntegerField(label='Number of files:', required=True)