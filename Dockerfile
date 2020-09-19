FROM cirrusci/flutter:1.20.3

WORKDIR /app

COPY . .

RUN sudo chown -R cirrus:cirrus /app

RUN flutter pub get

RUN sudo apt update

RUN sudo apt -y install ffmpeg

CMD [ "sh", "-c" , "flutter analyze --no-pub --preamble . && flutter test test/*"]