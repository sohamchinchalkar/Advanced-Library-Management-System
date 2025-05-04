import pandas as pd 
import numpy as np
from scipy.sparse import csr_matrix
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.datasets import load_svmlight_file
from joblib import Parallel, delayed
import heapq
from collections import defaultdict
from tqdm import tqdm

# File Paths
ratings_path = "trans.libsvm"  
user_mapping_path = "user_mapping.csv"
isbn_mapping_path = "book_mapping.csv"

# Step 1: Load mappings
print("Step 1: Loading Ratings.csv for mappings...")
user_mapping_df = pd.read_csv(user_mapping_path)
isbn_mapping_df = pd.read_csv(isbn_mapping_path)

print(f"Found {len(user_mapping_df)} users and {len(isbn_mapping_df)} books.")

# Step 2: Load Book Titles
print("Step 2: Preparing Book Titles...")
ordered_isbn_list = isbn_mapping_df.sort_values('Mapped_Book_ID')['Original_ISBN'].tolist()

print(f"Loaded {len(ordered_isbn_list)} book titles.")

# Step 3: Load LIBSVM Sparse Matrix
print("Step 3: Loading LIBSVM formatted ratings...")
X, _ = load_svmlight_file(ratings_path)

num_users, num_books = X.shape
print(f"Sparse matrix shape: {X.shape}, non-zero entries: {X.nnz}")

print("Step 4: Computing user-user similarity...")
user_similarity = cosine_similarity(X)
print("User-user similarity computed.")

# Quick lookup: books read by each user
X_coo = X.tocoo()
ratings_df = pd.DataFrame({
    'User_ID': X_coo.row,
    'Book_ID': X_coo.col,
    'Rating': X_coo.data
})

user_rated_books = ratings_df.groupby('User_ID')['Book_ID'].apply(set).to_dict()
user_book_rating = ratings_df.set_index(['User_ID', 'Book_ID'])['Rating'].to_dict()

# Step 5: Recommendation Function
def recommend_books_for_user(u, k=10):
    if u not in user_rated_books:
        return []

    similarities = user_similarity[u]
    similar_users = np.argsort(-similarities)[1:k+1]

    BK = set()
    for v in similar_users:
        BK.update(user_rated_books.get(v, set()))

    already_read = user_rated_books[u]
    candidate_books = BK - already_read

    book_scores = {}
    for b in candidate_books:
        numerator = 0
        denominator = 0
        for v in similar_users:
            rating = user_book_rating.get((v, b), None)
            if rating is not None:
                sim_score = similarities[v]
                numerator += sim_score * rating
                denominator += sim_score
        if denominator != 0:
            book_scores[b] = numerator / denominator

    top_5 = heapq.nlargest(5, book_scores.items(), key=lambda x: x[1])

    recommendations = []
    for book_id, score in top_5:
        user_id = f"User{u}"
        mapped_book_id = f"Book{book_id}"
        book_title = ordered_isbn_list[book_id] if book_id < len(ordered_isbn_list) else 'Unknown'

        recommendations.append({
            "User_ID": user_id,
            "Book_ID": mapped_book_id,
            "Book_Title": book_title,
            "Recommendation_Score": score
        })

    return recommendations

# Step 6: Generate Recommendations
print("Step 5: Generating recommendations...")
try:
    all_recommendations = Parallel(n_jobs=-1, backend='threading')(
        delayed(recommend_books_for_user)(u)
        for u in tqdm(range(num_users), desc='Generating Recommendations')
    )
except Exception as e:
    print(f"Error during parallel processing: {e}")
    all_recommendations = []

# Flatten the list
flattened_recommendations = [rec for sublist in all_recommendations if sublist for rec in sublist]

print(f"{len(flattened_recommendations)} recommendations generated.")

# Step 7: Save Results
if flattened_recommendations:
    recommendations_df = pd.DataFrame(flattened_recommendations)
    recommendations_df.to_csv('final_book_recommendations.csv', index=False)
    print("Final recommendations saved to final_book_recommendations.csv")
else:
    print("No recommendations generated.")

