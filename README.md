Designed and implemented a comprehensive Library Management System using MySQL, optimizing database performance and ensuring seamless book tracking, user management, and borrowing/returning functionalities.

Applied advanced database management techniques to structure relational data efficiently, enforcing constraints and indexing to accelerate query performance and maintain data integrity.

Developed custom SQL queries to enable real-time book search, automated reporting, and tracking of overdue fines, significantly enhancing administrative efficiency and user experience.

Implemented dynamic pricing for overdue fines and late fees based on demand and book availability, encouraging timely returns and better resource utilization.

Implemented a personalized book recommendation system using the K-Nearest Neighbors (KNN) algorithm, analyzing user borrowing history to suggest relevant books on the user portal and enhance engagement.

To generate recommendations, calculated a weighted average of the ratings for each book b in the candidate set by summing, for the top K similar users, each user’s rating of book b multiplied by the similarity between that user and the target user, and then dividing by the sum of the similarities.
In other words:
Predicted rating for user u and book b = (Sum over K of rating of book b by user i multiplied by similarity between user i and user u) divided by (Sum over K of similarity between user i and user u).

This approach improved recommendation accuracy by emphasizing ratings from users most similar to the target user.
