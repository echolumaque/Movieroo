//
//  MovieDetailViewController.swift
//  Movieroo
//
//  Created by Echo Lumaque on 2/24/25.
//

import UIKit
import SwiftUI

protocol MovieDetailView: AnyObject {
    var presenter: MovieDetailPresenter? { get set }
    func updateMovieDetails(_ result: Result<WrappedMovieDetail, NetworkingError>)
}

class MovieDetailViewController: UIViewController, MovieDetailView {
    var presenter: (any MovieDetailPresenter)?
    
    private let horizontalPadding: CGFloat = 16
    private let verticalPadding: CGFloat = 8
    
    private var movieId: Int!
    private var movieDetail: MovieDetail!
    private var movieReview: MovieReview!
    private var movieCertification: MovieCertification!
    private var movieRecommendations: [MovieDetail] = []
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let posterImageView = UIImageView()
    private let movieTitle = UILabel()
    
    private let movieSubtitles = UILabel()
    
    private let overview = UILabel()
    
    private let ratingDivider = Divider()
    
    private let recommendationDivider = Divider()
    
    private let reviewTableView = DynamicTableView()
    
    init(
        movieDetail: MovieDetail? = nil,
        movieReview: MovieReview? = nil,
        movieCertification: MovieCertification? = nil,
        movieRecommendations: [MovieDetail] = []
    ) {
        super.init(nibName: nil, bundle: nil)
        self.movieDetail = movieDetail
        self.movieReview = movieReview
        self.movieCertification = movieCertification
        self.movieRecommendations = movieRecommendations
    }
    
    init(movieId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.movieId = movieId
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureScrollView()
        configurePosterView()
        configureTitle()
        configureSubtitle()
        configureOverview()
        configureRecommendations()
        configureReviews()
        getMovieDetailAndReview()
    }
    
    func set(wrappedMovieDetail: WrappedMovieDetail) async {
        // MARK: - Poster
        posterImageView.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w1280\(wrappedMovieDetail.movieDetail.backdropPath).jpg")
        
        // MARK: - Title
        movieTitle.text = wrappedMovieDetail.movieDetail.originalTitle
        
        // MARK: - Subtitle
        let genres = wrappedMovieDetail.movieDetail.genres.map { $0.name }.joined(separator: ", ")
        let certification = wrappedMovieDetail.movieCertification
            .resultElement
            .first(where: { $0.iso3166_1 == "US" })?
            .releaseDates.first?
            .certification ?? ""
        
        var parsedString: [String] = []
        if !certification.isEmpty { parsedString.append(certification) }
        parsedString.append(contentsOf: [genres, wrappedMovieDetail.movieDetail.runtime.timeString])
        
        movieSubtitles.text = parsedString.joined(separator: " • ")
        
        // MARK: - Overview
        overview.text = wrappedMovieDetail.movieDetail.overview
        
        DispatchQueue.main.async {
            self.reviewTableView.reloadData()
            self.reviewTableView.invalidateIntrinsicContentSize()
        }
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Movie Details"
    }
    
    func configureScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        scrollView.pinToEdges(of: view)
        contentView.pinToEdges(of: scrollView)
        contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        contentView.addSubviews(
            posterImageView,
            movieTitle,
            movieSubtitles,
            overview
        )
    }
    
    func configurePosterView() {
        posterImageView.translatesAutoresizingMaskIntoConstraints = false
        posterImageView.contentMode = .scaleAspectFit
        if Environment.isForPreview {
            Task {
                posterImageView.image = await NetworkManager.shared.downloadImage(from: "https://image.tmdb.org/t/p/w1280\(movieDetail.backdropPath).jpg")
            }
        }

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            posterImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 2.0/3.0)
        ])
    }
    
    func configureTitle() {
        movieTitle.translatesAutoresizingMaskIntoConstraints = false
        if Environment.isForPreview { movieTitle.text = movieDetail.originalTitle }
        movieTitle.textColor = .label
        movieTitle.font = UIFont.preferredFont(for: .title1, weight: .bold)
        movieTitle.adjustsFontForContentSizeCategory = true
        movieTitle.adjustsFontSizeToFitWidth = true
        movieTitle.minimumScaleFactor = 0.75
        
        NSLayoutConstraint.activate([
            movieTitle.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: verticalPadding),
            movieTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            movieTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    func configureSubtitle() {
        movieSubtitles.translatesAutoresizingMaskIntoConstraints = false
        if Environment.isForPreview {
            let genres = movieDetail.genres.map { $0.name }.joined(separator: ", ")
            let certification = movieCertification
                .resultElement
                .first(where: { $0.iso3166_1 == "US" })?
                .releaseDates.first?
                .certification ?? ""
            
            movieSubtitles.text = "\(certification) • \(genres) • \(movieDetail.runtime.timeString)"
        }
        movieSubtitles.textColor = .secondaryLabel
        movieSubtitles.font = UIFont.preferredFont(forTextStyle: .subheadline)
        movieSubtitles.adjustsFontForContentSizeCategory = true
        movieSubtitles.adjustsFontSizeToFitWidth = true
        movieSubtitles.minimumScaleFactor = 0.75
        
        NSLayoutConstraint.activate([
            movieSubtitles.topAnchor.constraint(equalTo: movieTitle.bottomAnchor, constant: verticalPadding),
            movieSubtitles.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            movieSubtitles.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    func configureOverview() {
        let overviewDivider = Divider()
        contentView.addSubview(overviewDivider)
        
        overview.translatesAutoresizingMaskIntoConstraints = false
        overview.numberOfLines = 0
        overview.textColor = .label
        overview.font = UIFont.preferredFont(forTextStyle: .body)
        if Environment.isForPreview { overview.text = movieDetail.overview  }
        
        NSLayoutConstraint.activate([
            overviewDivider.topAnchor.constraint(equalTo: movieSubtitles.bottomAnchor, constant: verticalPadding),
            overviewDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            overviewDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            overviewDivider.heightAnchor.constraint(equalToConstant: 0.5),
            
            overview.topAnchor.constraint(equalTo: overviewDivider.bottomAnchor, constant: verticalPadding),
            overview.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            overview.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
    }
    
    func configureRecommendations() {
        let recommendationLabel = DynamicLabel(textColor: .secondaryLabel, font: UIFont.preferredFont(for: .title3, weight: .bold))
        recommendationLabel.text = "Also Watch:"
        
        let recommendationStackView = UIStackView()
        recommendationStackView.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        
        contentView.addSubviews(recommendationDivider, recommendationLabel, recommendationStackView)
        NSLayoutConstraint.activate([
            recommendationDivider.topAnchor.constraint(equalTo: overview.bottomAnchor, constant: verticalPadding),
            recommendationDivider.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            recommendationDivider.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            recommendationDivider.heightAnchor.constraint(equalToConstant: 0.5),
            
            recommendationLabel.topAnchor.constraint(equalTo: recommendationDivider.bottomAnchor, constant: verticalPadding),
            recommendationLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            recommendationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
        ])
    }
    
    func configureReviews() {
//        contentView.addSubview(reviewTableView)
//        reviewTableView.translatesAutoresizingMaskIntoConstraints = false
//        reviewTableView.estimatedRowHeight = 80
//        reviewTableView.rowHeight = UITableView.automaticDimension
//        reviewTableView.delegate = self
//        reviewTableView.dataSource = self
//        reviewTableView.tableFooterView = UIView(frame: .zero)
//        reviewTableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCell.reuseID)
//        reviewTableView.isScrollEnabled = false
//        
//        NSLayoutConstraint.activate([
//            reviewTableView.topAnchor.constraint(equalTo: ratingDivider.bottomAnchor, constant: verticalPadding),
//            reviewTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            reviewTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            reviewTableView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -verticalPadding)
//
//        ])
    }
    
    private func getMovieDetailAndReview() {
        Task { try await presenter?.fetchMovieDetals(for: movieId) }
    }
    
    func updateMovieDetails(_ result: Result<WrappedMovieDetail, NetworkingError>) {
        switch result {
        case .success(let wrappedMovieDetail):
            Task {
                await set(wrappedMovieDetail: wrappedMovieDetail)
            }
            
        case .failure(let failure):
            print("Network error: \(failure)")
        }
    }
}

extension MovieDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Environment.isForPreview {
            return movieReview.reviews.count
        } else {
            
            guard let presenter,
                  let wrappedMovieDetail = presenter.wrappedMovieDetail else {
                return 0
            }
            
            return wrappedMovieDetail.movieReview.reviews.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if Environment.isForPreview {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseID) as! ReviewCell
            let review = movieReview.reviews[indexPath.row]
            cell.set(review: review)
            
            return cell
        } else {
            guard let presenter,
                  let wrappedMovieDetail = presenter.wrappedMovieDetail else {
                return UITableViewCell(frame: .zero)
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewCell.reuseID) as! ReviewCell
            let review = wrappedMovieDetail.movieReview.reviews[indexPath.row]
            cell.set(review: review)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let presenter,
              let wrappedMovieDetail = presenter.wrappedMovieDetail else { return }
        
        let reviewUrl = wrappedMovieDetail.movieReview.reviews[indexPath.row].url
        presentSafariVC(with: URL(string: reviewUrl)!)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

#Preview {
    MovieDetailViewController(
        movieDetail: MovieDetail(adult: false, backdropPath: "/cVh8Af7a9JMOJl75ML3Dg2QVEuq.jpg", belongsToCollection: Movieroo.BelongsToCollection(id: 762512, name: "The Lion King (Reboot) Collection", posterPath: "/dGpIRn4Nqi63JO1RlKxjcPbQSAw.jpg", backdropPath: "/jIgM7YNVft0YGeXsqrh3oG5TWLx.jpg"), budget: 200000000, genres: [Movieroo.Genre(id: 12, name: "Adventure"), Movieroo.Genre(id: 10751, name: "Family"), Movieroo.Genre(id: 16, name: "Animation")], homepage: "https://movies.disney.com/mufasa-the-lion-king", id: 762509, imdbID: "tt13186482", originCountry: ["US"], originalLanguage: "en", originalTitle: "Mufasa: The Lion King", overview: "Mufasa, a cub lost and alone, meets a sympathetic lion named Taka, the heir to a royal bloodline. The chance meeting sets in motion an expansive journey of a group of misfits searching for their destiny.", popularity: 724.285, posterPath: "/9bXHaLlsFYpJUutg4E6WXAjaxDi.jpg", productionCompanies: [Movieroo.ProductionCompany(id: 2, logoPath: Optional("/wdrCwmRnLFJhEoH8GSfymY85KHT.png"), name: "Walt Disney Pictures", originCountry: "US")], productionCountries: [Movieroo.ProductionCountry(iso3166_1: "US", name: "United States of America")], releaseDate: "2024-12-18", revenue: 688700870, runtime: 118, spokenLanguages: [Movieroo.SpokenLanguage(englishName: "English", iso639_1: "en", name: "English")], status: "Released", tagline: "The story of an orphan who would be king.", title: "Mufasa: The Lion King", video: false, voteAverage: 7.448, voteCount: 1345),
        movieReview: MovieReview(id: 762509, page: 1, reviews: [Movieroo.Review(author: "r96sk", authorDetails: Movieroo.AuthorDetails(name: "", username: "r96sk", avatarPath: Optional("/mwR7rFHoDcobAx1i61I3skzMW3U.jpg"), rating: 8), content: "Rubbish poster aside, <em>\'Mufasa: The Lion King\'</em> is a success.\r\n\r\nI can\'t overlook that poster, how amateur can you get - it genuinely looks like something I\'d whip up seconds before the deadline. Thankfully, the movie itself is very good, it\'s one I enjoyed quite a bit. The animation is class, the lions look amazingly majestic. I will say the white ones look a bit iffy, but that\'s nothing even close to a big issue.\r\n\r\nThe voice cast are all perfectly good. Aaron Pierre, Kelvin Harrison Jr. (only now realising his character wasn\'t called Tucker... bit embarrassing on my part), John Kani et al. all merit props. The standouts for me, however, are Mads Mikkelsen and Lennie James - two actors I do love watching (or listening to, in this case), admittedly.\r\n\r\nMusic-wise, it\'s not the strongest - I can\'t recall any of the songs, to be honest. That\'s not actually a terrible thing though, as it means none of the musical numbers grated on me either - and that\'s always a win in my books. Elsewhere, Timon & Pumbaa are unamusing and wasted, but at the same time are unnecessarily forced into this prequel/sequel.\r\n\r\nObviously, this still falls far adrift of the beloved original animated film. Nevertheless, I\'ll hold it in higher esteem than the 2019 remake, even if I didn\'t overly mind that one to be fair. Oh, lastly, nice touch dedicating this to James Earl Jones at the get-go - was expecting it at the end.", createdAt: "2024-12-23T18:13:28.704Z", id: "6769a84846a5a438790b24d1", updatedAt: "2024-12-23T18:13:28.807Z", url: "https://www.themoviedb.org/review/6769a84846a5a438790b24d1"), Movieroo.Review(author: "CinemaSerf", authorDetails: Movieroo.AuthorDetails(name: "CinemaSerf", username: "Geronimo1967", avatarPath: Optional("/yz2HPme8NPLne0mM8tBnZ5ZWJzf.jpg"), rating: 6), content: "They\'ve been praying for rain for ages but are ill-prepared for when it finally comes and washes away the young \"Mufasa\" from the loving paws of his parents and out into the wilderness. Luckily, he is rescued by the friendly young cub \"Taka\" whose mother \"Eshe\" convinces his sceptical father \"Obasi\" to let her adopt him. The pair prove inseparable as they grow up, but the encroachment of a pride of angry white lions led by \"Kiros\" soon threatens their peaceful lives and forces the two to flee in search of a mystical land. Along the way they encounter the wily lioness \"Sarabi\" and her airborne early warning system \"Zazu\" and joining forces, have their work cut out for them crossing the snowy mountains. The whole story is regaled by the sagely \"Rafiki\" to a young cub \"Kiara\" and the underused, rough-round-the-edges, warthog/meerkat combo of \"Pumbaa\" and \"Timon\" so we know the ending all along. Not that jeopardy is in anyway the point here, it\'s not that kind of Disney film. It\'s really just a fairly shameless rip-off of the first, far superior, film that though it looks great with all the integrated live-action visuals has a story that\'s cheesily wafer thin. It\'s purpose is to set out the origins of the \"Lion King\" (1994) but all it really does is remind us of just how good that was and just how average this one is. They keep referring to the \"Circle of Life\" but barring a few meanderings from the orchestral score into the songs from the past, we are simply left with some banal offerings from Lin-Manuel Miranda best summed up by \"Bye Bye\" - straight from the Janet and John book of rhyming \"seas\" with \"trees\". Certainly, it looks great but it\'s also quite confusing whom it\'s for. The kids watching in the cinema with me were quickly bored by the undercooked story once the awe of the visuals had worn off. It\'s all perfectly watchable and is quite a testament to the arts of those in the CGI department well worthy of the big screen, but it\'s all instantly forgettable fayre that just sort of rolls along towards it\'s rousing denouement unremarkably.", createdAt: "2024-12-24T08:16:48.389Z", id: "676a6df0a05c09ebea7eae94", updatedAt: "2024-12-24T08:16:48.764Z", url: "https://www.themoviedb.org/review/676a6df0a05c09ebea7eae94")], totalPages: 1, totalResults: 2),
        movieCertification: MovieCertification(id: 762509, resultElement: [Movieroo.ResultElement(iso3166_1: "AS", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 4)]), Movieroo.ResultElement(iso3166_1: "AU", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 1), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 3), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 4)]), Movieroo.ResultElement(iso3166_1: "AZ", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "BG", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "BR", releaseDates: [Movieroo.ReleaseDateElement(certification: "10", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "CN", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 1), Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "CZ", releaseDates: [Movieroo.ReleaseDateElement(certification: "U", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "DE", releaseDates: [Movieroo.ReleaseDateElement(certification: "6", descriptors: ["Threat", "Stressful Scenes"], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "DO", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "ES", releaseDates: [Movieroo.ReleaseDateElement(certification: "A", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "FI", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "FR", releaseDates: [Movieroo.ReleaseDateElement(certification: "TP", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "GB", releaseDates: [Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 3), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 4), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 5)]), Movieroo.ResultElement(iso3166_1: "GU", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 4)]), Movieroo.ResultElement(iso3166_1: "HR", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "ID", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "IE", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 1), Movieroo.ReleaseDateElement(certification: "G", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "IL", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3), Movieroo.ReleaseDateElement(certification: "All", descriptors: [], iso639_1: "", type: 4)]), Movieroo.ResultElement(iso3166_1: "IN", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "en", type: 3)]), Movieroo.ResultElement(iso3166_1: "IT", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "JP", releaseDates: [Movieroo.ReleaseDateElement(certification: "G", descriptors: [], iso639_1: "", type: 3), Movieroo.ReleaseDateElement(certification: "G", descriptors: [], iso639_1: "", type: 4)]), Movieroo.ResultElement(iso3166_1: "KR", releaseDates: [Movieroo.ReleaseDateElement(certification: "ALL", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "KZ", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "LT", releaseDates: [Movieroo.ReleaseDateElement(certification: "N-7", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "MP", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 4)]), Movieroo.ResultElement(iso3166_1: "MX", releaseDates: [Movieroo.ReleaseDateElement(certification: "A", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "MY", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "NL", releaseDates: [Movieroo.ReleaseDateElement(certification: "9", descriptors: [], iso639_1: "en", type: 3)]), Movieroo.ResultElement(iso3166_1: "NO", releaseDates: [Movieroo.ReleaseDateElement(certification: "9", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "NZ", releaseDates: [Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "PA", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "PH", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "PL", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "PR", releaseDates: [Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 3), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 4), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 5)]), Movieroo.ResultElement(iso3166_1: "PT", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "SE", releaseDates: [Movieroo.ReleaseDateElement(certification: "11", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "SG", releaseDates: [Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "SK", releaseDates: [Movieroo.ReleaseDateElement(certification: "7", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "TH", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "TR", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "TW", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "UA", releaseDates: [Movieroo.ReleaseDateElement(certification: "0+", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "US", releaseDates: [Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 1), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 3), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 4), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 5)]), Movieroo.ResultElement(iso3166_1: "VI", releaseDates: [Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 4), Movieroo.ReleaseDateElement(certification: "PG", descriptors: [], iso639_1: "", type: 5)]), Movieroo.ResultElement(iso3166_1: "VN", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)]), Movieroo.ResultElement(iso3166_1: "ZA", releaseDates: [Movieroo.ReleaseDateElement(certification: "", descriptors: [], iso639_1: "", type: 3)])]),
        movieRecommendations: [
            MovieDetail(adult: false, backdropPath: "/cVh8Af7a9JMOJl75ML3Dg2QVEuq.jpg", belongsToCollection: Movieroo.BelongsToCollection(id: 762512, name: "The Lion King (Reboot) Collection", posterPath: "/dGpIRn4Nqi63JO1RlKxjcPbQSAw.jpg", backdropPath: "/jIgM7YNVft0YGeXsqrh3oG5TWLx.jpg"), budget: 200000000, genres: [Movieroo.Genre(id: 12, name: "Adventure"), Movieroo.Genre(id: 10751, name: "Family"), Movieroo.Genre(id: 16, name: "Animation")], homepage: "https://movies.disney.com/mufasa-the-lion-king", id: 762509, imdbID: "tt13186482", originCountry: ["US"], originalLanguage: "en", originalTitle: "Mufasa: The Lion King", overview: "Mufasa, a cub lost and alone, meets a sympathetic lion named Taka, the heir to a royal bloodline. The chance meeting sets in motion an expansive journey of a group of misfits searching for their destiny.", popularity: 724.285, posterPath: "/9bXHaLlsFYpJUutg4E6WXAjaxDi.jpg", productionCompanies: [Movieroo.ProductionCompany(id: 2, logoPath: Optional("/wdrCwmRnLFJhEoH8GSfymY85KHT.png"), name: "Walt Disney Pictures", originCountry: "US")], productionCountries: [Movieroo.ProductionCountry(iso3166_1: "US", name: "United States of America")], releaseDate: "2024-12-18", revenue: 688700870, runtime: 118, spokenLanguages: [Movieroo.SpokenLanguage(englishName: "English", iso639_1: "en", name: "English")], status: "Released", tagline: "The story of an orphan who would be king.", title: "Mufasa: The Lion King", video: false, voteAverage: 7.448, voteCount: 1345),
            MovieDetail(adult: false, backdropPath: "/cVh8Af7a9JMOJl75ML3Dg2QVEuq.jpg", belongsToCollection: Movieroo.BelongsToCollection(id: 762512, name: "The Lion King (Reboot) Collection", posterPath: "/dGpIRn4Nqi63JO1RlKxjcPbQSAw.jpg", backdropPath: "/jIgM7YNVft0YGeXsqrh3oG5TWLx.jpg"), budget: 200000000, genres: [Movieroo.Genre(id: 12, name: "Adventure"), Movieroo.Genre(id: 10751, name: "Family"), Movieroo.Genre(id: 16, name: "Animation")], homepage: "https://movies.disney.com/mufasa-the-lion-king", id: 762509, imdbID: "tt13186482", originCountry: ["US"], originalLanguage: "en", originalTitle: "Mufasa: The Lion King", overview: "Mufasa, a cub lost and alone, meets a sympathetic lion named Taka, the heir to a royal bloodline. The chance meeting sets in motion an expansive journey of a group of misfits searching for their destiny.", popularity: 724.285, posterPath: "/9bXHaLlsFYpJUutg4E6WXAjaxDi.jpg", productionCompanies: [Movieroo.ProductionCompany(id: 2, logoPath: Optional("/wdrCwmRnLFJhEoH8GSfymY85KHT.png"), name: "Walt Disney Pictures", originCountry: "US")], productionCountries: [Movieroo.ProductionCountry(iso3166_1: "US", name: "United States of America")], releaseDate: "2024-12-18", revenue: 688700870, runtime: 118, spokenLanguages: [Movieroo.SpokenLanguage(englishName: "English", iso639_1: "en", name: "English")], status: "Released", tagline: "The story of an orphan who would be king.", title: "Mufasa: The Lion King", video: false, voteAverage: 7.448, voteCount: 1345),
            MovieDetail(adult: false, backdropPath: "/cVh8Af7a9JMOJl75ML3Dg2QVEuq.jpg", belongsToCollection: Movieroo.BelongsToCollection(id: 762512, name: "The Lion King (Reboot) Collection", posterPath: "/dGpIRn4Nqi63JO1RlKxjcPbQSAw.jpg", backdropPath: "/jIgM7YNVft0YGeXsqrh3oG5TWLx.jpg"), budget: 200000000, genres: [Movieroo.Genre(id: 12, name: "Adventure"), Movieroo.Genre(id: 10751, name: "Family"), Movieroo.Genre(id: 16, name: "Animation")], homepage: "https://movies.disney.com/mufasa-the-lion-king", id: 762509, imdbID: "tt13186482", originCountry: ["US"], originalLanguage: "en", originalTitle: "Mufasa: The Lion King", overview: "Mufasa, a cub lost and alone, meets a sympathetic lion named Taka, the heir to a royal bloodline. The chance meeting sets in motion an expansive journey of a group of misfits searching for their destiny.", popularity: 724.285, posterPath: "/9bXHaLlsFYpJUutg4E6WXAjaxDi.jpg", productionCompanies: [Movieroo.ProductionCompany(id: 2, logoPath: Optional("/wdrCwmRnLFJhEoH8GSfymY85KHT.png"), name: "Walt Disney Pictures", originCountry: "US")], productionCountries: [Movieroo.ProductionCountry(iso3166_1: "US", name: "United States of America")], releaseDate: "2024-12-18", revenue: 688700870, runtime: 118, spokenLanguages: [Movieroo.SpokenLanguage(englishName: "English", iso639_1: "en", name: "English")], status: "Released", tagline: "The story of an orphan who would be king.", title: "Mufasa: The Lion King", video: false, voteAverage: 7.448, voteCount: 1345)
        ]
    )
}
