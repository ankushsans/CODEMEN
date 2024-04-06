from flask import Flask, render_template, request, send_file
import audioAnalyse
import subprocess
import os

app = Flask(__name__)

# Function to convert MP3 to WAV
def convert_to_wav(mp3_file,file_name):
    wav_file = file_name+".wav"
    subprocess.call(["ffmpeg", "-i", mp3_file, wav_file])
    return wav_file

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/convert', methods=['POST'])
def convert():
    if 'mp3_file' not in request.files:
        return "No file part"
    mp3_file = request.files['mp3_file']
    if mp3_file.filename == '':
        return "No selected file"
    mp3_file_path = "audioFiles/" + mp3_file.filename
    mp3_file.save(mp3_file_path)
    wav_file_path = convert_to_wav(mp3_file_path,mp3_file.filename)
    return send_file(wav_file_path, as_attachment=True)

@app.route('/audioAnalysis',methods=['GET'])
def audioAnalysis():
    pass

if __name__ == '__main__':
    if not os.path.exists("audioFiles"):
        os.makedirs("audioFiles")
    app.run(debug=True)

