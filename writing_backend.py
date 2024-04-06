import google.generativeai as genai
from TTS.api import TTS

tts = TTS("tts_models/en/ljspeech/tacotron2-DDC").to("cpu")

genai.configure(api_key="AIzaSyCcfJO4OjepfZxvbs-Qq7HdEaWkAON2BDs")
model = genai.GenerativeModel("gemini-pro")

chat = model.start_chat(history=[])

response = chat.send_message(
    "In the next prompt, I will write a piece of writing. Read it carefully and give proper advice. Look at each word and explain whether that word suits its position, or a synonym would be better. Check the facts and grammar and correct any mistakes."
)


def generate_response(user_input):
    response = chat.send_message(user_input)
    return response.text
