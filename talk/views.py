from rest_framework.views import APIView
from rest_framework.response import Response
import pickle

from talk.preprocess import Parser
from MKGen.generator import generate


class TalkView(APIView):
    """
    Receive message from the Front server then return creating message
    """
    parser = Parser()
    with open('models/clean_meidai.pkl', 'rb') as f:
        model = pickle.load(f)

    def get(self, request, format=None):
        query = request.GET.get('q')
        if not query:
            return Response({'error': 'Not exist query'})

        cleaned = self.parser.clean(query)
        tokens = self.parser.parse(cleaned)
        token = tokens[0]
        try:
            res_message = generate(token, self.model, num_of_words=25)
        except KeyError:
            res_message = 'キーが存在しないなんて・・・修正します！'

        if token == 'EOS':
            return Response({'error': 'Not exist query'})

        return Response({
            'query': token,
            'response': res_message
        })
