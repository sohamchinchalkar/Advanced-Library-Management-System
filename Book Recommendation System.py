import pandas as pd
from scipy.sparse import csr_matrix
from sklearn.metrics.pairwise import cosine_similarity
import sqlite3

# Connect to the renamed SQLite database
conn = sqlite3.connect("Group27_LibraryManagementSystem.db")  # Use full path if needed
cursor = conn.cursor()

# Step 1: Load user-book-rating data from the database
ratings_df = pd.read_sql_query("""
    SELECT user_id, book_id, rating FROM borrowed
    WHERE rating IS NOT NULL
""", conn)

# Step 2: Create user-book matrix
user_ids = ratings_df['user_id'].astype('category')
book_ids = ratings_df['book_id'].astype('category')

X = csr_matrix((ratings_df['rating'],
                (user_ids.cat.codes, book_ids.cat.codes)))

user_mapping = dict(enumerate(user_ids.cat.categories))
book_mapping = dict(enumerate(book_ids.cat.categories))

# Step 3: Compute similarity and recommendations
similarity = cosine_similarity(X)
recommendations = []

for user_index in range(X.shape[0]):
    sim_users = similarity[user_index]
    weighted_ratings = sim_users @ X
    normalization = sim_users.sum()
    scores = weighted_ratings / normalization if normalization > 0 else weighted_ratings
    recommendations.append(scores)

# Step 4: Create DataFrame for recommendations
recommendations_df = pd.DataFrame(recommendations)
recommendations_df['user_id'] = recommendations_df.index.map(user_mapping)

# Step 5: Melt to user-book-score format
melted_df = recommendations_df.drop(columns=['user_id']).copy()
melted_df.columns = [book_mapping[i] for i in melted_df.columns]
melted_df['user_id'] = recommendations_df['user_id']
final_df = melted_df.melt(id_vars='user_id', var_name='book_id', value_name='score')

# Step 6: Remove books already rated by users
rated_pairs = set(zip(ratings_df.user_id, ratings_df.book_id))
final_df = final_df[~final_df.set_index(['user_id', 'book_id']).index.isin(rated_pairs)]

# Step 7: Get top 5 recommendations per user
top_recommendations = final_df.groupby('user_id').apply(
    lambda x: x.sort_values('score', ascending=False).head(5)
).reset_index(drop=True)

# Step 8: Save recommendations back to the SQL database
top_recommendations.to_sql("recommendations", conn, if_exists="replace", index=False)

# Close connection
conn.close()
