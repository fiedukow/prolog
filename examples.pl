op(rodzic(franek, darek)).
op(rodzic(franek, iga)).
op(rodzic(gosia, darek)).
op(rodzic(gosia, iga)).
op(ojciec(swirski, franek)).
op(matka(dominika, franek)).
op(kobieta(dominika)).
op(mezczyzna(swirski)).
op(ojciec(franek, darek)).
op(ojciec(franek, iga)).
op(matka(gosia, darek)).
op(matka(gosia, iga)).
op(mezczyzna(franek)).
op(brat(darek, iga)).
op(siostra(iga, darek)).
op(rodzenstwo(iga, darek)).
op(rodzenstwo(darek, iga)).
op(kobieta(iga)).
op(mezczyzna(darek)).

example(pos(dziadek(swirski, iga))).
example(pos(dziadek(swirski, darek))).
example(pos(babcia(dominika, iga))).
example(pos(babcia(dominika, darek))).
example(neg(dziadek(swirski,swirski))).
example(neg(dziadek(swirski,iga))).
example(neg(dziadek(swirski,darek))).
example(neg(dziadek(swirski,dominika))).
example(neg(dziadek(iga,iga))).
example(neg(dziadek(iga,darek))).
example(neg(dziadek(iga,dominika))).
example(neg(dziadek(darek,darek))).
example(neg(dziadek(darek,dominika))).
example(neg(dziadek(dominika,dominika))).
example(neg(babcia(swirski,swirski))).
example(neg(babcia(swirski,iga))).
example(neg(babcia(swirski,darek))).
example(neg(babcia(swirski,dominika))).
example(neg(babcia(iga,iga))).
example(neg(babcia(iga,darek))).
example(neg(babcia(iga,dominika))).
example(neg(babcia(darek,darek))).
example(neg(babcia(darek,dominika))).
example(neg(babcia(dominika,dominika))).

people([swirski, franek, dominika, iga, gosia, darek]).

