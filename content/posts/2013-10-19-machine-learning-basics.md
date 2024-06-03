---
layout: post
title: "Machine learning basics"
date: "2013-10-19 17:39:00"
comments: false
categories:
- dev
tags:
- ml
---

Well, after wanting to do this for years, I finally bit the bullet and enroled in the infamous [Machine Learning class](https://www.coursera.org/course/ml) run by Andrew Ng through Coursera and Stanford. Professor Andrew Ng is Director of the Stanford Artificial Intelligence Lab, the main AI research organization at Stanford, with 20 professors and about 150 students/post docs. The first revision of this course ran in 2008, where Andrew started SEE (Stanford Engineering Everywhere), which was Stanford's first attempt at free, online distributed education.

As of mid 2013, the course has been revised many times since it incubation, but its roots remain. It's a 10 week program requiring about 10 hours of dedicated study per week. It looks completely awesome, and goes deep into the theory behind current ML techniques including topics such as neural networks, linear and logistic regression, basic cost functions, regularization, support vector machines, anomaly detection, recommender systems, and much more. I also love the decision to use [GNU Octave](https://www.gnu.org/software/octave/) as the means to express our thinking/algorithms, allowing us to stay focused on whats important and not get bogged down with stupid language specific (C++, Java, Python, R, whatevs) implementation quirks. Programming assignments are submitted directly from within Octave using the course provided scripts, the quality of submissions is assessed in realtime...extremely slick!

Machine learning is such a rich and exciting field, which in my opinion is one area in software that can really make impactful changes to the way we currently go about things. Software in general needs to be way smarter. I am most intruiged about applying machine learning to data mining, and hope to build some useful software by applying some of the knowledge imparted (stay posted for my prototypes in github).


### Machine learning definition

Arthur Samual (1959). Machine Learning: Field of study that gives computers the ability to learn without explicitly being programmed.

Tom Mitchell (1998). Well-posed Learning Problem: A computer program is said to learn from experience E with respect to some task T and some performance measure P, if its performance on T, as measured by P, improves with experience E.

In a checkers learning algorithm, experience E would be having the algorithm play many thousands of games against itself, task T would be playing checkers, the performance measure P would be the probability that it wins the game of checkers against a new opponent. 


### Supervised learning

Supervised learning is where we teach the computer to learn something. When provided with a set of "right answers", the task of the algorithm is to provide more right answers. 

Regression problem, or in other words, to predict continuous valued output (e.g. house price given block size).

Classification problem, discrete valued output (e.g. magignant or benign, true or false, 1 or 2 or 3 or 4, and so on)

Feature or attribute, an input into the learning algorithm (e.g. for breast cancer detection features may include things like age, tumor size, clump thickness, unifomity of cell size, uniformity of cell shape)

What would be ideal is if our learning algorithm could accomodate an infinitely sized feature set. As we'll see later, support vector machines, will show us a neat mathematical trick that make this possible.


### Unsupervised learning

Where the computer learns by itself. Involves automatically creating structure, and discovering facts from a ton of data. Unlike supervised learning, where the data is marked explicitly.

Clustering algorithm. Will clump and classify data together based on feature. Some examples include Google news, social network analysis, market segmentation, astonomical data analysis.

Cocktail party problem - by using multiple recording sources (microphones) placed at different locations, and having multiple sources of noise (e.g. people, music), filter out the multiple sources to a single source.

Sample [GNU Octave](https://www.gnu.org/software/octave/) syntax, linear algebra operations with vectors and matrices feels very baked in, and natural to articulate your thoughts...perfect for playing and testing algorithms.

    [W,s,v] = svd((repmat(sum(x.*x,1), size(x,1), q).*x)*x');
