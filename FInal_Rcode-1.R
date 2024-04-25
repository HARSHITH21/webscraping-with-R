## Installation and loading the necessary libraries
install.packages("rvest")
install.packages("ggplot2")
install.packages("dplyr")
install.packages("lubridate")

library(rvest)
library(ggplot2)
library(dplyr)
library(lubridate)

## Define the function to extract articles from a specific volume
extract_volume_articles <- function(volume) {
  # Initialize lists to store extracted data
  titles <- authors <- correspondence_authors <- correspondence_emails <- publish_dates <- abstracts <- keywords <- c()
  
  # Construct the URL for the specified volume
  url <- paste0("https://humgenomics.biomedcentral.com/articles?query=&volume=", volume, "&searchType=&tab=keyword")
  
  # Read the HTML content of the page
  page <- read_html(url)
  
  # Extract all href attributes
  href_values <- page %>% html_nodes("a[data-test='title-link']") %>% html_attr("href")
  
  # Construct absolute URLs
  absolute_urls <- paste0("https://humgenomics.biomedcentral.com", href_values)
  
  # Loop through each article URL and extract data
  for (article_url in absolute_urls) {
    # Read the HTML content of the article page
    article_page <- read_html(article_url)
    
    # Extract title
    title <- article_page %>% html_node("h1.c-article-title") %>% html_text(trim = TRUE)
    titles <- c(titles, title)
    
    # Extract author names
    author_names <- article_page %>% html_nodes("ul.c-article-author-list a[data-test='author-name']") %>% html_text(trim = TRUE) %>% paste(collapse = ", ")
    authors <- c(authors, author_names)
    
    # Extract corresponding author's name
    corresponding_author_name <- article_page %>% html_node("p#corresponding-author-list a") %>% html_text(trim = TRUE)
    correspondence_authors <- c(correspondence_authors, corresponding_author_name)
    
    # Extract corresponding author's email address
    corresponding_author_email <- article_page %>% html_node("p#corresponding-author-list a") %>% html_attr("href") %>% gsub("mailto:", "", .)
    correspondence_emails <- c(correspondence_emails, corresponding_author_email)
    
    # Extract the publication date
    publication_date <- article_page %>% html_node("time") %>% html_attr("datetime")
    publish_dates <- c(publish_dates, publication_date)
    
    # Extract abstract content
    abstract <- article_page %>% html_node("section[aria-labelledby='Abs1'] p") %>% html_text(trim = TRUE)
    abstracts <- c(abstracts, abstract)
    
    # Extract keyword elements
    keyword_elements <- article_page %>% html_nodes("ul.c-article-subject-list a")
    
    # Extract keywords if keyword elements are found, otherwise set to NA
    if (length(keyword_elements) > 0) {
      keywords_text <- keyword_elements %>% html_text(trim = TRUE) %>% paste(collapse = ", ")
    } else {
      keywords_text <- NA
    }
    keywords <- c(keywords, keywords_text)
  }
  
  # Replace NA values with placeholders
  correspondence_authors[is.na(correspondence_authors)] <- "Unknown"
  correspondence_emails[is.na(correspondence_emails)] <- "Unknown"
  publish_dates[is.na(publish_dates)] <- "Unknown"
  abstracts[is.na(abstracts)] <- "No abstract available"
  keywords[is.na(keywords)] <- "No keywords available"
  
  # Combine extracted data into a data frame
  articles_df <- data.frame(
    Title = titles,
    Authors = authors,
    Correspondence_Author = correspondence_authors,
    Correspondence_Email = correspondence_emails,
    Publish_Date = publish_dates,
    Abstract = abstracts,
    Keywords = keywords,
    stringsAsFactors = FALSE
  )
  
  return(articles_df)
}

## Call the function to extract articles from volumes 1 to 5
volumes_1_to_5_articles <- bind_rows(lapply(1:5, extract_volume_articles))

## Write cleaned data to CSV
write.csv(volumes_1_to_5_articles, file = "Human_Genomics_Data_Volumes_1_to_5.csv", row.names = FALSE)

## Function to plot the number of papers published in each year
plot_papers_published <- function() {
  # Range of years to analyze
  start_year <- 2006
  end_year <- 2024
  
  # Initialize vectors to store year and paper counts
  years <- start_year:end_year
  paper_counts <- numeric(length(years))
  
  # Loop through each year to get the paper count
  for (i in 1:length(years)) {
    volume <- years[i] - 2005
    url <- paste0("https://humgenomics.biomedcentral.com/articles?query=&volume=", volume, "&searchType=&tab=keyword")
    page <- read_html(url)
    
    # Extract the number of search results
    result_count <- page %>%
      html_node("h2[data-test='result-title'] strong[data-test='search-results-count']") %>%
      html_text() %>%
      as.numeric()
    
    paper_counts[i] <- ifelse(is.na(result_count), 0, result_count)
  }
  
  # Create a data frame
  papers_df <- data.frame(year = years, papers_published = paper_counts)
  
  # Plotting
  ggplot(papers_df, aes(x = year, y = papers_published)) +
    geom_line() +
    geom_point() +
    labs(title = "Number of Papers Published Each Year",
         x = "Year",
         y = "Number of Papers Published")
}

## Function to plot the number of articles per corresponding author
plot_articles_per_corresponding_author <- function(data) {
  data %>%
    group_by(Correspondence_Author) %>%
    summarise(Num_Articles = n()) %>%
    ggplot(aes(x = reorder(Correspondence_Author, -Num_Articles), y = Num_Articles)) +
    geom_bar(stat = "identity") +
    coord_flip() +
    labs(title = "Number of Articles per Corresponding Author",
         x = "Corresponding Author",
         y = "Number of Articles") +
    theme(axis.text.y = element_text(size = 6))  # Adjust font size for better readability
}

## Function to plot the number of articles per publication year
plot_articles_per_publication_year <- function(data) {
  data %>%
    mutate(Publish_Year = lubridate::year(Publish_Date)) %>%
    group_by(Publish_Year) %>%
    summarise(Num_Articles = n()) %>%
    ggplot(aes(x = Publish_Year, y = Num_Articles)) +
    geom_bar(stat = "identity", fill = "skyblue") +
    labs(title = "Number of Articles Published Each Year",
         x = "Publication Year",
         y = "Number of Articles Published")
}


## Call the functions to plot
plot_papers_published()
plot_articles_per_corresponding_author(volumes_1_to_5_articles)
plot_articles_per_publication_year(volumes_1_to_5_articles)
