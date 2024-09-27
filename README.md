
# Human Genomics Web Scraping and Data Analysis using R

## Project Description
This project focuses on extracting and analyzing data from the Human Genomics journal using web scraping techniques in R. The main objective is to demonstrate the significance of web scraping by retrieving data from a specified journal, organizing it, and visualizing the extracted information for meaningful insights.

## Key Features
- **Web Scraping**: Scraped data from a journal (Human Genomics) to gather real-time information for analysis.
- **Data Storage**: Segregated and stored relevant data fields in a CSV file for easy access and differentiation.
- **Data Analysis**: Analyzed the scraped data and created meaningful visualizations to demonstrate key metrics.
  
## Tools & Libraries Used
- **R Programming Language**
- **RStudio**
- **Packages Used**:
  - `rvest`: For web scraping.
  - `ggplot2`: For data visualization.
  - `lubridate`: For date manipulation.
  - `dplyr`: For data cleaning and structuring.

## Setup Instructions
1. Install R and RStudio on your local machine.
2. Install the required packages:
   ```R
   install.packages(c("rvest", "ggplot2", "lubridate", "dplyr"))
   ```
3. Set the file path inside RStudio to save the extracted data.

## Project Workflow
1. **Web Scraping**: Scrape data from the Human Genomics journal by providing the URL and extracting the content into an HTML page. Then convert it into text and read it using the `read_html()` function.
2. **Data Processing**: Organize the scraped data into a structured format and save it as a CSV file for further analysis.
3. **Data Visualization**: Generate visualizations to explore the relationships between different variables such as the number of papers published per year and the number of articles by each corresponding author.

## Example Visualizations
- **No. of Papers Published vs. Year**
- **Corresponding Author vs. No. of Articles**
  
## Challenges Faced
- Difficulties in cleaning and organizing the data into specific fields.
- Sorting large data sets for visualization (e.g., large bar graphs).
- Reduced the scope of data extraction to improve efficiency (Volumes 1 to 5 instead of Volumes 1 to 18).

## Conclusion
Through this project, we successfully scraped and analyzed real-time data from the Human Genomics journal. The project highlights the importance of web scraping in business and research and its ability to provide up-to-date, real-time data for decision-making.
