# 🌿 Plant Detection Guide / গাছ সনাক্তকরণ গাইড

## কিভাবে কাজ করে? / How It Works?

### বাংলায় / In Bangla:

**Plant Detection** একটি **TensorFlow Lite (TFLite)** মডেল ব্যবহার করে আপনার গাছের ছবি থেকে গাছের ধরন সনাক্ত করে।

#### ধাপগুলো / Steps:

1. **ছবি তোলা / Select Image:**
   - ক্যামেরা দিয়ে নতুন ছবি তোলা
   - গ্যালারি থেকে ছবি নির্বাচন করা

2. **মডেল লোড করা / Model Loading:**
   - অ্যাপ প্রথমে TFLite মডেল লোড করে
   - মডেল `assets/tflite/model.tflite` থেকে লোড হয়

3. **ছবি প্রক্রিয়াকরণ / Image Processing:**
   - ছবি 224x224 পিক্সেলে রিসাইজ করা হয়
   - RGB ফরম্যাটে রূপান্তর করা হয়
   - 0-1 রেঞ্জে নরমালাইজ করা হয়

4. **Prediction / পূর্বাভাস:**
   - মডেল ছবি বিশ্লেষণ করে
   - সম্ভাব্য গাছের ধরন এবং আত্মবিশ্বাসের শতাংশ দেখায়

5. **ফলাফল / Result:**
   - গাছের নাম/ধরন
   - আত্মবিশ্বাসের শতাংশ (%)
   - স্বয়ংক্রিয়ভাবে Category সাজেস্ট করা

---

### In English:

**Plant Detection** uses a **TensorFlow Lite (TFLite)** model to identify plant types from your plant photos.

#### Steps:

1. **Select Image:**
   - Take a new photo with camera
   - Select image from gallery

2. **Model Loading:**
   - App loads the TFLite model first
   - Model is loaded from `assets/tflite/model.tflite`

3. **Image Processing:**
   - Image is resized to 224x224 pixels
   - Converted to RGB format
   - Normalized to 0-1 range

4. **Prediction:**
   - Model analyzes the image
   - Shows possible plant type and confidence percentage

5. **Result:**
   - Plant name/type
   - Confidence percentage (%)
   - Automatically suggests category

---

## 📱 কিভাবে ব্যবহার করবেন? / How to Use?

### Method 1: Add Plant Screen থেকে / From Add Plant Screen

1. **Add Plant** স্ক্রিনে যান
2. **Image** ফিল্ডে ক্লিক করুন
3. **"Detect Plant"** অপশন নির্বাচন করুন
4. ক্যামেরা বা গ্যালারি থেকে ছবি নির্বাচন করুন
5. Detection result দেখুন
6. **"Use This Image"** বাটনে ক্লিক করুন
7. Category স্বয়ংক্রিয়ভাবে সিলেক্ট হবে

### Method 2: Standalone Detection Screen

1. Menu থেকে **"Detect Plant"** নির্বাচন করুন
2. ক্যামেরা বা গ্যালারি থেকে ছবি নির্বাচন করুন
3. Result দেখুন
4. Image এবং Category ব্যবহার করতে পারেন

---

## 🔧 Setup Instructions / সেটআপ নির্দেশনা

### Step 1: TFLite Model যোগ করুন

1. একটি **TensorFlow Lite** মডেল ডাউনলোড করুন:
   - [TensorFlow Hub](https://tfhub.dev/)
   - [Kaggle Models](https://www.kaggle.com/models)
   - [Model Zoo](https://github.com/tensorflow/models)

2. Model file টি `assets/tflite/model.tflite` হিসেবে সেভ করুন

### Step 2: Labels File তৈরি করুন

1. `assets/tflite/labels.txt` ফাইল তৈরি করুন
2. প্রতিটি লাইনে একটি label লিখুন:

```
Flower
Fruit
Indoor
Outdoor
Bonsai
Cactus
Vegetable
Tree
Leaf
Plant
Herb
Shrub
```

### Step 3: Model Requirements

- **Input Size:** 224x224x3 (RGB image)
- **Output:** Classification probabilities
- **Format:** .tflite file

---

## ⚠️ Important Notes / গুরুত্বপূর্ণ নোট

1. **Model না থাকলে:**
   - App কাজ করবে কিন্তু detection warning দেখাবে
   - আপনি manually category select করতে পারবেন

2. **Best Results:**
   - ভাল আলোতে ছবি তুলুন
   - গাছের পুরো অংশ দেখান
   - Background কম রাখুন

3. **Offline Work:**
   - সব কিছু offline কাজ করে
   - Internet connection লাগে না

4. **Accuracy:**
   - Model এর quality এর উপর নির্ভর করে
   - Confidence 70%+ হলে ভাল result

---

## 🎯 Example Workflow / উদাহরণ

1. **Add Plant** → Image field → **Detect Plant**
2. Camera/Gallery থেকে ছবি নির্বাচন
3. Model analyze করে → "Rose - 85% confidence"
4. Category automatically "Flower" select হয়
5. Image save হয়
6. Plant add করুন

---

## 🔍 Troubleshooting / সমস্যা সমাধান

### Model load হচ্ছে না:
- Check `assets/tflite/model.tflite` file আছে কিনা
- `pubspec.yaml` এ assets path আছে কিনা check করুন
- App restart করুন

### Low confidence:
- ভাল আলোতে ছবি তুলুন
- গাছের clear view নিন
- Model টি ভাল quality এর কিনা check করুন

### Error messages:
- Model file format check করুন
- Labels file format check করুন
- App logs দেখুন

---

## 📚 Resources / সম্পদ

- [TensorFlow Lite Documentation](https://www.tensorflow.org/lite)
- [Flutter TFLite Plugin](https://pub.dev/packages/tflite_flutter)
- [Plant Classification Models](https://www.kaggle.com/datasets?search=plant+classification)

---

**Happy Plant Detection! 🌱**

