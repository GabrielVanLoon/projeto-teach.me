from django.http    import JsonResponse
from rest_framework import status

from src.models.instructor import InstructorModel

class InstructorController:

    def register(self, request):
        (data, http_status)   = ({ }, status.HTTP_400_BAD_REQUEST)
        
        if request.method != 'POST':
            data = { 'error': 'invalid http method. Use POST instead.'}
            return JsonResponse(data, status=http_status)

        try:
            InstructorModel().register(request.POST)
            data = { 'message': 'successfully registered instructor.'}
            http_status = status.HTTP_200_OK

        except Exception as e:
            data = { 'error': str(e) }

        return JsonResponse(data, status=http_status)

    def update(self, request):
        (data, http_status)   = ({ }, status.HTTP_400_BAD_REQUEST)
        
        if request.method != 'POST':
            data = { 'error': 'invalid http method. Use POST instead.'}
            return JsonResponse(data, status=http_status)

        try:
            InstructorModel().update(request.POST)
            data = { 'message': 'successfully updated instructor.'}
            http_status = status.HTTP_200_OK

        except Exception as e:
            data = { 'error': str(e) }

        return JsonResponse(data, status=http_status)


    def search(self, request):
        (data, http_status)   = ({ }, status.HTTP_400_BAD_REQUEST)
        
        if request.method != 'GET':
            data = { 'error': 'invalid http method. Use GET instead.'}
            return JsonResponse(data, status=http_status)

        try:
            instructor = InstructorModel().search(request.GET)
            data = { 'instructor': instructor }
            http_status = status.HTTP_200_OK

        except Exception as e:
            data = { 'error': str(e) }

        return JsonResponse(data, status=http_status)

    def get_instructors(self, request):
        (data, http_status)   = ({ }, status.HTTP_400_BAD_REQUEST)
        
        if request.method != 'POST':
            data = { 'error': 'invalid http method. Use POST instead.'}
            return JsonResponse(data, status=http_status)
        try:
            n_rows, instructors_dict = InstructorModel().get_instructors(request.POST)
            data = { 
                'message': '{} instructor(s) found'.format(n_rows),
                'rows': n_rows,
                'results': instructors_dict,
            } 
            http_status = status.HTTP_200_OK
        except Exception as e:
            data = { 'error': str(e) }
        return JsonResponse(data, status=http_status)