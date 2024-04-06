import google.generativeai as genai
from TTS.api import TTS

tts = TTS("tts_models/en/ljspeech/tacotron2-DDC").to("cpu")

genai.configure(api_key="AIzaSyCcfJO4OjepfZxvbs-Qq7HdEaWkAON2BDs")
model = genai.GenerativeModel("gemini-pro")

chat = model.start_chat(history=[])

response = chat.send_message(
    "You are to act as a debate opponent for me to practice on. From the next prompt, I will start my arguments. Pick the opposite side and simulate a respectful debate."
)


def generate_response(user_input):
    response = chat.send_message(user_input)
    return response.text
