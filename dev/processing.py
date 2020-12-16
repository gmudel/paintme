import torch
import torchvision.transforms as transforms
import torchvision.models as models

import PIL
import matplotlib.pyplot as plt

# values obtained from https://pytorch.org/docs/stable/torchvision/models.html
TORCH_MEAN = [0.485, 0.456, 0.406]
TORCH_STD = [0.229, 0.224, 0.225]

NORMAL_MEAN = [0., 0., 0.]
NORMAL_STD = [1., 1., 1.]

# Does mobilenet/resnet_18 allow for different sizes?
NN_IMPUT_SIZE = 224

feature_extractor = models.vgg19(pretrained=True).features
#feature_extractor = models.mobilenet_v2(pretrained=True).features
#feature_extractor = models.squeezenet1_1(pretrained=True).features
for param in feature_extractor:
    param.requires_grad = False

#print(feature_extractor)

# This may be problematic 
#feature_extractor.type(torch.cuda.FloatTensor)

def preprocess(img):
    transform = transforms.Compose([
        transforms.Resize([NN_IMPUT_SIZE, NN_IMPUT_SIZE]),
        transforms.ToTensor(),
        transforms.Normalize(mean=TORCH_MEAN, std=TORCH_STD),
        transforms.Lambda(lambda x: x[None]),
    ])
    return transform(img)

def deprocess(img):
    neg_mean = [-x for x in TORCH_MEAN]
    inv_std = [1/x for x in TORCH_STD]
    transform = transforms.Compose([
        transforms.Lambda(lambda x: x[0]),
        transforms.Normalize(mean=[0, 0, 0], std=(inv_std)),
        transforms.Normalize(mean=(neg_mean), std=[1, 1, 1]),
        transforms.Lambda(rescale),
        transforms.ToPILImage(),
    ])
    return transform(img)

def rescale(x):
    low, high = x.min(), x.max()
    x_rescaled = (x - low) / (high - low)
    return x_rescaled

def extract_features(minibatch):
    features = []
    prev_output = minibatch
    for module in feature_extractor._modules.values():
        output = module(prev_output)
        features.append(output)
        prev_output = output
    return features

'''
basic test

img = PIL.Image.open("django/static/vincentvangogh/Vincent_van_Gogh_99.jpg")
img_preprocessed = preprocess(img)
img_deprocessed = deprocess(img_preprocessed)

plt.figure()
plt.imshow(img)
plt.figure()
plt.imshow(img_deprocessed)

plt.show()
'''