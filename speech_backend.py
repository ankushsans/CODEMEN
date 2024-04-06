import google.generativeai as genai
from TTS.api import TTS

tts = TTS("tts_models/en/ljspeech/tacotron2-DDC").to("cpu")

genai.configure(api_key="AIzaSyCcfJO4OjepfZxvbs-Qq7HdEaWkAON2BDs")
model = genai.GenerativeModel("gemini-pro")

chat = model.start_chat(history=[])


def generate_audio(text, file_path):
    tts.tts_to_file(text=text, file_path=file_path)


def generate_sample_text():
    response = chat.send_message(
        "Generate sample text that is medium-level difficulty to pronounce. It should be arround 50 words."
    )
    return response.text


def generate_response():
    response = chat.send_message("Say something random around 20 words.")
    return response.text


# if __name__ == "__main__":
#     for i in range(20):
#         text = generate_sample_text()
#         with open(f"static/cache/text{i}", "w") as file:
#             file.write(text)
#         generate_audio(text, f"static/cache/speech{i}")
