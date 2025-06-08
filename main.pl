% Prolong Rental Matching
%
% Δομή προγράμματος:
% 1. Κύριο μενού και λειτουργίες εισόδου/εξόδου
% 2. Διαδραστική λειτουργία για έναν πελάτη
% 3. Μαζική λειτουργία για όλους τους πελάτες
% 4. Λειτουργία δημοπρασίας με επαναληπτική διαδικασία
% 5. Βοηθητικά κατηγορήματα για επεξεργασία δεδομένων

% ============================================================================
% ΦΟΡΤΩΣΗ ΑΡΧΕΙΩΝ ΚΑΙ ΚΥΡΙΟ ΜΕΝΟΥ
% ============================================================================

% Αυτόματη φόρτωση των αρχείων houses.pl και requests.pl
:- encoding(utf8).
:- consult('houses.pl').
:- consult('requests.pl').

% Κύριο κατηγόρημα εκκίνησης
run :-
    show_menu,
    get_choice(Choice),
    process_choice(Choice).

% Εμφάνιση μενού επιλογών
show_menu :-
    nl,
    write('Μενού:'), nl,
    write('======'), nl,
    write('1 - Προτιμήσεις ενός πελάτη'), nl,
    write('2 - Μαζικές προτιμήσεις πελατών'), nl,
    write('3 - Επιλογή πελατών μέσω δημοπρασίας'), nl,
    write('0 - Έξοδος'), nl,
    write('Επιλογή:').

% Διαχείριση επιλογής χρήστη
get_choice(Choice) :-
    read(Choice).

% Επεξεργασία επιλογής
process_choice(0) :- !.  % Έξοδος από το πρόγραμμα

process_choice(1) :-     % Διαδραστική λειτουργία
    !,
    interactive_mode,
    run.

process_choice(2) :-     % Μαζική λειτουργία
    !,
    batch_mode,
    run.

process_choice(3) :-     % Λειτουργία δημοπρασίας
    !,
    auction_mode,
    run.

process_choice(_) :-     % Μη έγκυρη επιλογή
    write('Επίλεξε έναν αριθμό μεταξύ 0 έως 3!'), nl,
    run.

% ============================================================================
% ΔΙΑΔΡΑΣΤΙΚΗ ΛΕΙΤΟΥΡΓΙΑ (ΕΠΙΛΟΓΗ 1)
% ============================================================================

interactive_mode :-
    write('Δώσε τις παρακάτω πληροφορίες:'), nl,
    write('=============================='), nl,
    
    % Συλλογή απαιτήσεων από χρήστη
    write('Ελάχιστο Εμβαδόν: '), read(MinArea),
    write('Ελάχιστος αριθμός υπνοδωματίων: '), read(MinBedrooms),
    write('Να επιτρέπονται κατοικίδια; (yes/no) '), read(PetsRequired),
    write('Από ποιον όροφο και πάνω να υπάρχει ανελκυστήρας; '), read(ElevatorFloor),
    write('Ποιο είναι το μέγιστο ενοίκιο που μπορείς να πληρώσεις; '), read(MaxRent),
    write('Πόσα θα έδινες για ένα διαμέρισμα στο κέντρο της πόλης (στα ελάχιστα τετραγωνικά); '), read(CenterRent),
    write('Πόσα θα έδινες για ένα διαμέρισμα στα προάστια της πόλης (στα ελάχιστα τετραγωνικά); '), read(SuburbRent),
    write('Πόσα θα έδινες για κάθε τετραγωνικό διαμερίσματος πάνω από το ελάχιστο;'), read(ExtraAreaPrice),
    write('Πόσα θα έδινες για κάθε τετραγωνικό κήπου; '), read(GardenPrice),
    nl,
    
    % Δημιουργία δομής απαιτήσεων
    Requirements = req(MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    
    % Εύρεση κατάλληλων διαμερισμάτων
    findall(House, house(House, _, _, _, _, _, _, _, _), AllHouses),
    compatible_houses(Requirements, AllHouses, CompatibleHouses),
    
    % Εμφάνιση αποτελεσμάτων
    (   CompatibleHouses = [] ->
        write('Δεν υπάρχει κατάλληλο σπίτι!'), nl
    ;   display_houses(CompatibleHouses),
        find_best_house(CompatibleHouses, BestHouse),
        write('Προτείνεται η ενοικίαση του διαμερίσματος στην διεύθυνση: '), write(BestHouse), nl
    ).

% ============================================================================
% ΜΑΖΙΚΗ ΛΕΙΤΟΥΡΓΙΑ (ΕΠΙΛΟΓΗ 2)
% ============================================================================

batch_mode :-
    findall(Client, request(Client, _, _, _, _, _, _, _, _, _), Clients),
    process_all_clients(Clients).

process_all_clients([]).
process_all_clients([Client|Rest]) :-
    write('Κατάλληλα διαμερίσματα για τον πελάτη: '), write(Client), write(':'), nl,
    write('======================================='), nl,
    
    % Λήψη απαιτήσεων πελάτη
    request(Client, MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    Requirements = req(MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    
    % Εύρεση κατάλληλων διαμερισμάτων
    findall(House, house(House, _, _, _, _, _, _, _, _), AllHouses),
    compatible_houses(Requirements, AllHouses, CompatibleHouses),
    
    % Εμφάνιση αποτελεσμάτων
    (   CompatibleHouses = [] ->
        write('Δεν υπάρχει κατάλληλο σπίτι!'), nl
    ;   display_houses(CompatibleHouses),
        find_best_house(CompatibleHouses, BestHouse),
        write('Προτείνεται η ενοικίαση του διαμερίσματος στην διεύθυνση: '), write(BestHouse), nl
    ),
    nl,
    process_all_clients(Rest).

% ============================================================================
% ΛΕΙΤΟΥΡΓΙΑ ΔΗΜΟΠΡΑΣΙΑΣ (ΕΠΙΛΟΓΗ 3)
% ============================================================================
% Η δημοπρασία εκτελεί μια επαναληπτική διαδικασία εκχώρησης σπιτιών σε πελάτες,
% προσπαθώντας να βρει το βέλτιστο ταίριασμα με βάση τις προσφορές και τις προτιμήσεις.
% Επίσης επιλύει συγκρούσεις πελατών που "κερδίζουν" πάνω από ένα σπίτι.

auction_mode :-
    % Εύρεση όλων των πελατών και των προτιμήσεών τους
    findall(Client, request(Client, _, _, _, _, _, _, _, _, _), Clients),
    
    % ΒΗΜΑ 1: Βρες ποια σπίτια είναι κατάλληλα για κάθε πελάτη
    (   find_houses(Clients, ClientHousePairs) ->
        % ΒΗΜΑ 2: Βρες για κάθε σπίτι ποιοι πελάτες το διεκδικούν
        (   find_bidders(ClientHousePairs, Bidders) ->
            % ΒΗΜΑ 3: Εκχώρησε σπίτια στους καλύτερους προσφέροντες
            (   refine_houses(Bidders, FinalAssignments) ->
                % Εμφάνιση αποτελεσμάτων δημοπρασίας
                display_auction_results(Clients, FinalAssignments)
            ;   write('Σφάλμα κατά την επίλυση δημοπρασίας'), nl, fail
            )
        ;   write('Σφάλμα κατά την εύρεση ανταγωνιστών'), nl, fail
        )
    ;   write('Σφάλμα κατά την εύρεση κατάλληλων διαμερισμάτων'), nl, fail
    ).

% ============================================================================
% ΚΑΤΗΓΟΡΗΜΑΤΑ ΣΥΜΒΑΤΟΤΗΤΑΣ ΔΙΑΜΕΡΙΣΜΑΤΩΝ
% ============================================================================

% Έλεγχος συμβατότητας ενός διαμερίσματος με απαιτήσεις πελάτη
compatible_house(req(MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice), 
                Address) :-
    house(Address, Bedrooms, Area, _InCenter, Floor, Elevator, Pets, _Garden, ActualRent),
    
    % Έλεγχος βασικών απαιτήσεων
    Area >= MinArea,
    Bedrooms >= MinBedrooms,
    
    % Έλεγχος κατοικιδίων
    (PetsRequired = no ; Pets = yes),
    
    % Έλεγχος ανελκυστήρα
    (Floor < ElevatorFloor ; Elevator = yes),
    
    % Έλεγχος ενοικίου με βάση την προσφορά πελάτη
    offer(req(MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
          Address, ClientOffer),
    ClientOffer >= ActualRent.

% Εύρεση όλων των συμβατών διαμερισμάτων για έναν πελάτη
compatible_houses(_, [], []).
compatible_houses(Requirements, [House|Rest], [House|Compatible]) :-
    compatible_house(Requirements, House),
    !,
    compatible_houses(Requirements, Rest, Compatible).
compatible_houses(Requirements, [_|Rest], Compatible) :-
    compatible_houses(Requirements, Rest, Compatible).

% ============================================================================
% ΚΑΤΗΓΟΡΗΜΑΤΑ ΕΠΙΛΟΓΗΣ ΚΑΛΥΤΕΡΟΥ ΔΙΑΜΕΡΙΣΜΑΤΟΣ
% ============================================================================

% Εύρεση του καλύτερου διαμερίσματος με βάση τα κριτήρια προτίμησης
find_best_house(Houses, BestHouse) :-
    find_cheaper(Houses, CheaperHouses),
    (   CheaperHouses = [SingleHouse] ->
        BestHouse = SingleHouse
    ;   find_biggest_garden(CheaperHouses, BiggestGardenHouses),
        (   BiggestGardenHouses = [SingleHouse] ->
            BestHouse = SingleHouse
        ;   find_biggest_house(BiggestGardenHouses, [BestHouse|_])
        )
    ).

% Εύρεση διαμερισμάτων με το χαμηλότερο ενοίκιο
find_cheaper(Houses, CheaperHouses) :-
    findall(Rent-House, (member(House, Houses), house(House, _, _, _, _, _, _, _, Rent)), RentHousePairs),
    keysort(RentHousePairs, [MinRent-_|_]),
    findall(House, member(MinRent-House, RentHousePairs), CheaperHouses).

% Εύρεση διαμερισμάτων με τον μεγαλύτερο κήπο
find_biggest_garden(Houses, BiggestGardenHouses) :-
    findall(Garden-House, (member(House, Houses), house(House, _, _, _, _, _, _, Garden, _)), GardenHousePairs),
    keysort(GardenHousePairs, Sorted),
    reverse(Sorted, [MaxGarden-_|_]),
    findall(House, member(MaxGarden-House, GardenHousePairs), BiggestGardenHouses).

% Εύρεση διαμερισμάτων με το μεγαλύτερο εμβαδόν
find_biggest_house(Houses, BiggestHouses) :-
    findall(Area-House, (member(House, Houses), house(House, _, Area, _, _, _, _, _, _)), AreaHousePairs),
    keysort(AreaHousePairs, Sorted),
    reverse(Sorted, [MaxArea-_|_]),
    findall(House, member(MaxArea-House, AreaHousePairs), BiggestHouses).

% ============================================================================
% ΚΑΤΗΓΟΡΗΜΑΤΑ ΔΗΜΟΠΡΑΣΙΑΣ
% ============================================================================

% Εύρεση προτιμήσεων όλων των πελατών
find_houses([], []).
find_houses([Client|Rest], [Client-PreferredHouses|ClientHousePairs]) :-
    request(Client, MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    Requirements = req(MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    
    findall(House, house(House, _, _, _, _, _, _, _, _), AllHouses),
    compatible_houses(Requirements, AllHouses, CompatibleHouses),
    
    % Ταξινόμηση διαμερισμάτων κατά προτίμηση
    sort_by_preference(CompatibleHouses, PreferredHouses),
    
    find_houses(Rest, ClientHousePairs).

% Ταξινόμηση διαμερισμάτων κατά σειρά προτίμησης
sort_by_preference(Houses, SortedHouses) :-
    findall(Score-House, (member(House, Houses), calculate_preference_score(House, Score)), ScoredHouses),
    keysort(ScoredHouses, Sorted),
    findall(House, member(_-House, Sorted), SortedHouses).

% Δημιουργεί μια βαθμολογία προτίμησης για κάθε σπίτι:
% - Χαμηλότερο σκορ = καλύτερη επιλογή
% - Βάση: ενοίκιο (βαρύτητα x1000), κήπος (αρνητική), εμβαδόν (αρνητική)

calculate_preference_score(House, Score) :-
    house(House, _, Area, _, _, _, _, Garden, Rent),
    % Πρώτα ενοίκιο (x1000), μετά κήπος (-x10), μετά εμβαδόν (-x1)
    Score is Rent * 1000 - Garden * 10 - Area.

% Εύρεση ανταγωνιστών για κάθε διαμέρισμα
find_bidders(ClientHousePairs, Bidders) :-
    findall(House, house(House, _, _, _, _, _, _, _, _), AllHouses),
    find_bidders_for_houses(AllHouses, ClientHousePairs, Bidders).

find_bidders_for_houses([], _, []).
find_bidders_for_houses([House|Rest], ClientHousePairs, [House-Clients|Bidders]) :-
    findall(Client, (member(Client-Houses, ClientHousePairs), member(House, Houses)), Clients),
    find_bidders_for_houses(Rest, ClientHousePairs, Bidders).

% Εύρεση καλύτερων προσφορών για κάθε διαμέρισμα
find_best_bidders([], []).
find_best_bidders([House-Clients|Rest], [House-BestClient|BestBidders]) :-
    (   Clients = [] ->
        BestClient = none
    ;   Clients = [SingleClient] ->
        % Έλεγχος αν ο μοναδικός πελάτης μπορεί πραγματικά να νοικιάσει το σπίτι
        (   can_afford_house(SingleClient, House) ->
            BestClient = SingleClient
        ;   BestClient = none
        )
    ;   % Πολλοί πελάτες - βρες τον καλύτερο που μπορεί να πληρώσει
        (   find_highest_bidder(House, Clients, Winner) ->
            BestClient = Winner
        ;   BestClient = none
        )
    ),
    find_best_bidders(Rest, BestBidders).

% Εύρεση πελάτη με την υψηλότερη προσφορά
find_highest_bidder(House, Clients, BestClient) :-
    % Βρες όλους τους πελάτες που μπορούν πραγματικά να πληρώσουν το σπίτι
    findall(Offer-Client, (
        member(Client, Clients), 
        get_client_offer(Client, House, Offer),
        house(House, _, _, _, _, _, _, _, ActualRent),
        Offer >= ActualRent
    ), ValidOfferClientPairs),
    
    (   ValidOfferClientPairs = [] ->
        % Κανένας δεν μπορεί να πληρώσει το σπίτι
        fail
    ;   % Βρες τον καλύτερο από αυτούς που μπορούν
        keysort(ValidOfferClientPairs, Sorted),
        reverse(Sorted, [_-BestClient|_])
    ).

% Λήψη προσφοράς πελάτη για συγκεκριμένο διαμέρισμα
get_client_offer(Client, House, Offer) :-
    request(Client, MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    Requirements = req(MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    offer(Requirements, House, Offer).

% Έλεγχος αν ο πελάτης μπορεί να πληρώσει το σπίτι
can_afford_house(Client, House) :-
    get_client_offer(Client, House, Offer),
    house(House, _, _, _, _, _, _, _, ActualRent),
    Offer >= ActualRent.

% ============================================================================
% ΕΠΙΛΥΣΗ ΔΗΜΟΠΡΑΣΙΑΣ ΚΑΙ ΑΝΑΘΕΣΗ ΣΠΙΤΙΩΝ
% ============================================================================
% Αρχικά βρίσκονται οι καλύτεροι "πλειοδότες" για κάθε σπίτι.
% Αν κάποιος πελάτης έχει πάρει πάνω από ένα σπίτι, επιλέγεται το καλύτερο για αυτόν
% και η διαδικασία επαναλαμβάνεται μέχρι κάθε πελάτης να έχει το πολύ ένα σπίτι.

refine_houses(Bidders, FinalAssignments) :-
    find_best_bidders(Bidders, BestBidders),
    
    findall(House-Client, (member(House-Client, BestBidders), Client \= none), ValidAssignments),
    
    % Έλεγχος για συγκρούσεις (πελάτης με πολλά σπίτια)
    findall(Client, member(_-Client, ValidAssignments), AllWinners),
    sort(AllWinners, UniqueWinners),
    length(AllWinners, TotalWins),
    length(UniqueWinners, UniqueClients),
    
    (   TotalWins > UniqueClients ->  % Υπάρχουν συγκρούσεις
        % Επίλυση συγκρούσεων
        resolve_auction_conflicts(ValidAssignments, [], FinalAssignments)
    ;   % Δεν υπάρχουν συγκρούσεις
        FinalAssignments = ValidAssignments
    ).

% Επίλυση συγκρούσεων: πελάτες που έχουν εκχωρηθεί σε περισσότερα σπίτια
% κρατούν μόνο το πιο προτιμητέο. Τα υπόλοιπα διατίθενται ξανά στους υπόλοιπους.
% Η διαδικασία επαναλαμβάνεται αναδρομικά.

resolve_auction_conflicts(ValidAssignments, AlreadyAssigned, FinalAssignments) :-
    % Βρες πελάτες που κερδίζουν πολλά σπίτια
    findall(Client-Houses, (
        member(_-Client, ValidAssignments),
        findall(House, member(House-Client, ValidAssignments), Houses),
        length(Houses, Count),
        Count > 1
    ), ConflictedClientsDup),
    sort(ConflictedClientsDup, ConflictedClients),
    
    (   ConflictedClients = [] ->
        % Δεν υπάρχουν άλλες συγκρούσεις
        append(AlreadyAssigned, ValidAssignments, FinalAssignments)
    ;   % Επίλυση συγκρούσεων
        % Κάθε πελάτης κρατάει το προτιμότερό του σπίτι
        select_preferred_for_conflicted(ConflictedClients, SelectedAssignments),
        
        % Βρες τα σπίτια που απελευθερώθηκαν
        findall(House, member(House-_, SelectedAssignments), KeptHouses),
        findall(House, (
            member(House-_, ValidAssignments),
            \+ member(House, KeptHouses)
        ), ReleasedHouses),
        
        % Βρες όλους τους πελάτες που δεν έχουν ακόμη σπίτι στον τρέχοντα γύρο
        append(AlreadyAssigned, SelectedAssignments, TotalAssigned),
        findall(Client, member(_-Client, TotalAssigned), AllAssignedClients),
        findall(Client, request(Client, _, _, _, _, _, _, _, _, _), AllClients),
        findall(Client, (member(Client, AllClients), \+ member(Client, AllAssignedClients)), UnassignedClients),
        
        % Για κάθε απελευθερωμένο σπίτι, βρες ποιοι από τους unassigned clients μπορούν να το νοικιάσουν
        findall(House-Client, (
            member(House, ReleasedHouses),
            member(Client, UnassignedClients),
            can_afford_house(Client, House)
        ), NewBiddings),
        
        % Δημιουργία νέων bidders για τα σπίτια
        findall(House-Clients, (
            member(House, ReleasedHouses),
            findall(Client, member(House-Client, NewBiddings), Clients)
        ), NewBidders),
        
        % Εύρεση νέων νικητών για τα σπίτια
        find_best_bidders(NewBidders, NewWinners),
        findall(House-Client, (member(House-Client, NewWinners), Client \= none), AvailableForReassignment),
        
        % Νέος γύρος για τα ελευθερα σπίτια
        append(AlreadyAssigned, SelectedAssignments, NewAlreadyAssigned),
        resolve_auction_conflicts(AvailableForReassignment, NewAlreadyAssigned, FinalAssignments)
    ).

% Επιλογή προτιμότερων σπιτιών για πελάτες με συγκρούσεις
select_preferred_for_conflicted([], []).
select_preferred_for_conflicted([Client-Houses|Rest], [PreferredHouse-Client|SelectedRest]) :-
    % Βρες τη σειρά προτίμησης του πελάτη
    request(Client, MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    Requirements = req(MinArea, MinBedrooms, PetsRequired, ElevatorFloor, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice),
    
    findall(H, house(H, _, _, _, _, _, _, _, _), AllHouses),
    compatible_houses(Requirements, AllHouses, CompatibleHouses),
    sort_by_preference(CompatibleHouses, PreferredOrder),
    
    % Βρες το προτιμότερο από τα σπίτια που κέρδισε
    find_most_preferred_from_list(PreferredOrder, Houses, PreferredHouse),
    
    select_preferred_for_conflicted(Rest, SelectedRest).

% Βρες το προτιμότερο σπίτι από μια δεδομένη λίστα
find_most_preferred_from_list([House|_], AvailableHouses, House) :-
    member(House, AvailableHouses), !.
find_most_preferred_from_list([_|Rest], AvailableHouses, PreferredHouse) :-
    find_most_preferred_from_list(Rest, AvailableHouses, PreferredHouse).
find_most_preferred_from_list([], [House|_], House) :- !.  % πάρε το πρώτο διαθέσιμο
find_most_preferred_from_list([], [], _) :- !, fail.    

% ============================================================================
% ΚΑΤΗΓΟΡΗΜΑ ΥΠΟΛΟΓΙΣΜΟΥ ΠΡΟΣΦΟΡΑΣ
% ============================================================================

% Υπολογισμός προσφοράς πελάτη για συγκεκριμένο διαμέρισμα
offer(req(MinArea, _, _, _, MaxRent, CenterRent, SuburbRent, ExtraAreaPrice, GardenPrice), Address, Offer) :-
    house(Address, _, Area, InCenter, _, _, _, Garden, _),
    
    % Βασικό ενοίκιο ανάλογα με την τοποθεσία
    (InCenter = yes -> BasicRent = CenterRent ; BasicRent = SuburbRent),
    
    % Επιπλέον κόστος για παραπάνω εμβαδόν
    ExtraArea is Area - MinArea,
    (ExtraArea > 0 -> ExtraAreaCost is ExtraArea * ExtraAreaPrice ; ExtraAreaCost = 0),
    
    % Επιπλέον κόστος για κήπο
    GardenCost is Garden * GardenPrice,
    
    % Συνολική προσφορά
    TotalOffer is BasicRent + ExtraAreaCost + GardenCost,
    
    % Εφαρμογή ανώτατου ορίου
    (TotalOffer > MaxRent -> Offer = MaxRent ; Offer = TotalOffer).

% ============================================================================
% ΚΑΤΗΓΟΡΗΜΑΤΑ ΕΜΦΑΝΙΣΗΣ
% ============================================================================

% Εμφάνιση διαμερισμάτων
display_houses([]).
display_houses([House|Rest]) :-
    display_house_details(House),
    display_houses(Rest).

% Εμφάνιση διαμερίσματος
display_house_details(Address) :-
    house(Address, Bedrooms, Area, InCenter, Floor, Elevator, Pets, Garden, Rent),
    write('Κατάλληλο σπίτι στην διεύθυνση: '), write(Address), nl,
    write('Υπνοδωμάτια: '), write(Bedrooms), nl,
    write('Εμβαδόν: '), write(Area), nl,
    write('Εμβαδόν κήπου: '), write(Garden), nl,
    write('Είναι στο κέντρο της πόλης: '), write(InCenter), nl,
    write('Επιτρέπονται κατοικίδια: '), write(Pets), nl,
    write('Όροφος: '), write(Floor), nl,
    write('Ανελκυστήρας: '), write(Elevator), nl,
    write('Ενοίκιο: '), write(Rent), nl,
    nl.

% Εμφάνιση αποτελεσμάτων δημοπρασίας
display_auction_results([], _).
display_auction_results([Client|Rest], Assignments) :-
    (   member(House-Client, Assignments) ->
        write('O πελάτης '), write(Client), write(' θα νοικιάσει το διαμέρισμα στην διεύθυνση: '), write(House), nl
    ;   write('O πελάτης '), write(Client), write(' δεν θα νοικιάσει κάποιο διαμέρισμα!'), nl
    ),
    display_auction_results(Rest, Assignments).
