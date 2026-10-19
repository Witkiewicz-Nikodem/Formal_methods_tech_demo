# Demo technologiczne metody formalne
W tym repo przygotowałem krótkie demo technologiczne. Weryfikowania układów napisanych w verilogu uczę się z tej [strony](https://formal.org/). Aktualnie ukończyłem szóstą lekcję kursu "Introduction to formal verification". 

W trakcie rozmowy telefonicznej poruszyślimy temat AES jako potencjalnego pacjenta do weryfikacji. Przygotowałem weryfikację pojedyńczej rundy, dalej opisuję metodologię, i wnioski. 

Rundę AES można opisać kombinacyjnę, co z perspektywy weryfikacji formalnej jest dość proste, więc wrzucam też jedno z zadań kursu żeby uchwycić dowód układu sekwencyjnego i techniki z tym związane.

## AES
### metodologia
W skład rundy w AES wchodzą algorytmy: Sbox, shift rows, Mix column, add key. Szyfrogram musi dać się zdeszyfrować, AES osiąga to w ten sposób, że każdy z tych algorytmów - czyli runda też - są odwracalne co pozwala zbudować algorytm deszyfrujący.

W pierwszym kroku zaimplementowałem każdy z algorytmów rundy oraz ich inwersję i zweryfikowałem ich własności. Następnie zaimplementowałem rundę AES i także zweryfikowałem. Każdy eksperyment (implementacja + weryfikacja algortymów lub całej rundy) ma swój osobny folder. Implementacje powstały prawie w całości z wykorzystaniem clauda, a pliki odpowiedzialne za werfyfikację napisałem ręcznie.

### Wyniki
#### Sbox
ten algorytm zaimplementowałem na dwa sposoby. Pierwszy z nich jest referencyjny, czyli bezpośrednie wykonanie operacji matematycznych, które stoją za konstrukcją Sbox'a. Drugi z nich to sprowadzenie Sbox'a do ogromnego bloku case, który podstawia każde możliwe wejście odpowiednim wyjściem. 

Dodatkowo zaimplementowałem algorytm inwersji Sboxa, też w postaci bloku case. 

__Udowodnione własności__
* implementacja referencyjna jest równoważna implementacji blokiem case.
* Złożenie implementacji blokiem case z jej inwersją, działa poprawnie - wejście jest równe wyjściu.

#### Shift rows
ten algorytm zaimplementowałem na dwa sposoby. Shift_rows jest w gruncie rzeczy permutacją ale mając dwie implementacje można zmniejszyć ryzyko błedu. 

Dodatkowo zaimplementowałem algorytm inwersji shift rows.

__Udowodnione własności__
* dwie implementacje są sobie równoważne.
* Złożenie implementacji blokiem case z jej inwersją, działa poprawnie - wejście jest równe wyjściu.

#### Mix columns
ten algorytm zaimplementowałem na dwa sposoby. Pierwszy z nich jest referencjny, czyli bezpośrednie wykonanie operacji matematycznych, które stoją za konstrukcją Mix columns. Drugi z nich to sprowadzenie Mix column do kilku bloków podstawowych operacji.

Dodatkowo zaimplementowałem algorytm inwersji Sboxa, też w postaci bloku case. 

__Udowodnione własności__
* implementacja referencyjna jest równoważna uproszczonej implementacji.
* Złożenie implementacji blokiem case z jej inwersją, działa poprawnie - wejście jest równe wyjściu.

#### add_key
ten algorytm to wyłącznie jeden xor, zrobiłem jedną implementację - porównanie implementacji uproszczonej z referencyjną oraz inwersja nie mają tu sensu.  

__Udowodniona własność__
* algorytm jest odwrotny sam do siebie.

### ROUND
Wykorzystując powyższe algorytmy zaimplementowałem rundę AES i jej inwersję. 

__Udowodniona własność__
ROUND_INV(ROUND(m,k),k) = m oraz ROUND(ROUND_INV(m,k),k). Czyli Runda oraz jej inwersja są sobie odwrotne.

### Obserwacje i Wnioski
* Wszystkie zaimplementowane algorytmy są kombinacyjne, co sprawia że w dowodzie nie trzeba uwzględniać różnych stanów, bo ich poprostu nie ma. Dlatego ich dowody sprowadzają się do tego że w jednym cyklu zegara dane własności są spełnione.

* dowody pojedyńczych algorytmów wykonane były stosunkowo szybko, do minuty. Runda potrzebowała 6 godzin obliczeń na domowym PC. Dowodzenie całego AESA, może być nie możliwe do przeprowadzenia, na moim PC napewno nie do zrobienia. Ale to jeszcze nie znaczy że nic nie da się zrobić. Gdybym miał dalej dowodzić AES to rozbiłbym dowód na dwie części. 1 to już wykonany dowód rundy. W drugiej zaimplementowałbym AES, w którym zamockowałbym rozszerzanie klucza oraz rundę AES'a i dowodziłbym pozostałe własności np. poprawna ilość rund. Dla pewności, że implementacje referencyjne oraz uproszczone nie powielają tych samych błędów przetestowałbym implemetancję na podstawie gotowych wektorów testowych. 


## Zadanie z kursu: APB pipeline register
Poprzednie układy były kombinacyjne, więc wykorzystałem najprostszą metodę dowodzenia. Tutaj wykorzystuję metodę, która dowodzi, że własności zawsze są spełnione w układzie sekwencyjnym. Podaję to w celu pokazania kontrastu. Weryfikacja układów kombinacyjnych jest dość prosta, tam gdzie weryfikacja staje się trudna to są właśnie układy sekwencyjne. 

Dalszą, część opisu wygenerowałem claudem. Opisuje ona Weryfikowany układ oraz konkretną technikę dowodzenia. 

### Weryfikowany układ
Peryferium APB z dwustopniowym potokiem zapisu. Dane z magistrali przechodzą przez trzy rejestry:

* `pipe1` – przechwytuje `pwdata` przy poprawnym zapisie APB (`psel && pwrite && penable`),
* `pipe2` – przechwytuje `pipe1` w kolejnym cyklu,
* `out_reg` – przechwytuje `pipe2` cykl później i ustawia `data_valid`.

Obok danych płyną bity ważności `write_en1` i `write_en2`, które mówią, czy w danym stopniu znajduje się faktyczny zapis. Licznik `credits` zlicza zapisy będące "w locie": rośnie o 1, gdy zapis wchodzi do pierwszego stopnia, i maleje o 1, gdy trafia do `out_reg`.

### Metoda
Dla układów sekwencyjnych samo BMC nie wystarcza, bo sprawdza własność tylko do ograniczonej głębokości. Wynik "do głębokości N nie ma błędu" nie oznacza, że błąd nie wystąpi nigdy. Dlatego użyłem trybu `prove` w SBY, który dowodzi własności indukcyjnie:

1. **Baza:** własność zachodzi w stanie początkowym (po resecie).
2. **Krok indukcyjny:** jeśli własność zachodzi w dowolnym stanie, to zachodzi też w następnym.

Po udanym dowodzie własność obowiązuje dla każdej możliwej sekwencji wejść i w każdym cyklu, a nie tylko w pierwszych N.

### Udowodnione własności
* **Safety:** `credits <= 2`. Potok ma dwa stopnie, więc w locie mogą być co najwyżej dwa zapisy.
* **Spójność licznika ze stanem potoku:** `credits == write_en1 + write_en2`.

Własności sprawdzane są po resecie (`f_past_valid`), a układ zawsze startuje od resetu (`initial assume(rst)`).

### Wnioski
Własność safety sama nie przechodzi kroku indukcyjnego, mimo że układ jest poprawny. Solver w kroku indukcyjnym zaczyna od dowolnego stanu, także nieosiągalnego, np. takiego, w którym `credits = 2`, a oba bity ważności są zerowe, i z niego po jednym cyklu dochodzi do `credits = 3`. Dopiero dodanie drugiej własności, wiążącej licznik z faktycznym stanem potoku, wyklucza takie stany i pozwala domknąć dowód. Safety wynika z niej bezpośrednio, bo `write_en1 + write_en2 <= 2`.

Wniosek praktyczny: przy dowodzeniu układów sekwencyjnych sama interesująca nas własność zwykle nie jest indukcyjna i trzeba ją wzmocnić o niezmienniczki opisujące osiągalne stany. Ich szukanie na podstawie kontrprzykładów z nieudanego kroku indukcyjnego jest główną techniką w tego typu dowodach, a w tym układzie wystarczyła jedna dodatkowa niezmienniczka.