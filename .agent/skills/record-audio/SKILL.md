---
name: record-audio
description: Use this skill when the user asks how to add the record package to a Flutter project and use it to record audio.
---

# Record Audio with `record` Package

## Goal
To successfully add the `record` package to a project and implement functionality to record audio to a file. 

## Instructions
When tasked with implementing audio recording using the `record` package, follow these steps:

1. **Add the Package Dependency:**
   Add `record` to the project's dependencies:
   ```bash
   flutter pub add record
   ```

2. **Initialize an AudioRecorder:**
   Instantiate the primary object that controls the recording process. You typically want to hold onto a single instance of `AudioRecorder`.
   ```dart
   import 'package:record/record.dart';
   
   final recorder = AudioRecorder();
   ```

3. **Request User Permission:**
   Before recording, you must verify that the user has granted microphone permissions. Keep in mind that you may also need to configure platform-specific permissions (like `Info.plist` on iOS/macOS or `AndroidManifest.xml` on Android).
   ```dart
   if (await recorder.hasPermission()) {
     // Permission granted, proceed with recording.
   } else {
     // Permission denied, handle accordingly.
   }
   ```

4. **Create a Recording Configuration:**
   Create a `RecordConfig` object to specify the recording settings such as the encoder, sample rate, and channels. You can also enable features like auto gain, echo cancellation, and noise suppression.
   ```dart
   final recordConfig = const RecordConfig(
     encoder: AudioEncoder.pcm16bits,
     sampleRate: 24000,
     numChannels: 1,
     autoGain: true,
     echoCancel: true,
     noiseSuppress: true,
   );
   ```

5. **Start Recording to a File:**
   Call the `start` method on the `AudioRecorder`, providing the configuration and the destination file path.
   ```dart
   // Provide a valid path for the audio file depending on the platform.
   final audioFilePath = 'myRecording.wav';
   await recorder.start(recordConfig, path: audioFilePath);
   ```

6. **Control an Ongoing Recording (Optional):**
   You can pause and resume the recording if needed.
   ```dart
   await recorder.pause();
   await recorder.resume();
   ```

7. **Stop Recording:**
   To stop the recording and retrieve the final path of the saved file, call the asynchronous `stop` method.
   ```dart
   final path = await recorder.stop();
   print('Recording stopped. File saved to: $path');
   ```

8. **Dispose of the Recorder:**
   When you are completely finished using the `AudioRecorder` (for instance, in the `dispose` method of a `StatefulWidget`), you must release its resources to prevent memory leaks or microphone locking.
   ```dart
   await recorder.dispose();
   ```

## Constraints
- Ensure proper permission checks (`hasPermission()`) are performed before attempting to start a recording.
- Always `dispose()` of the `AudioRecorder` instance when it is no longer needed.
