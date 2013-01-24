op(ojciec(marek,edek)).
op(ojciec(edek,jozek)).
op(matka(marta,jozek)).
op(matka(alicja,marta)).

example(pos(przodek2(marek,jozek))). % dziadek(marek,jozek)
example(pos(przodek2(alicja,jozek))). % babcia(alicja,jozek)
example(neg(przodek2(marek,marek))).
example(neg(przodek2(marek,edek))).
example(neg(przodek2(marek,marta))).
example(neg(przodek2(marek,alicja))).
example(neg(przodek2(edek,marek))).
example(neg(przodek2(edek,edek))).
example(neg(przodek2(edek,jozek))).
example(neg(przodek2(edek,marta))).
example(neg(przodek2(edek,alicja))).
example(neg(przodek2(jozek,marek))).
example(neg(przodek2(jozek,edek))).
example(neg(przodek2(jozek,jozek))).
example(neg(przodek2(jozek,marta))).
example(neg(przodek2(jozek,alicja))).
example(neg(przodek2(marta,marek))).
example(neg(przodek2(marta,edek))).
example(neg(przodek2(marta,jozek))).
example(neg(przodek2(marta,marta))).
example(neg(przodek2(marta,alicja))).
example(neg(przodek2(alicja,marek))).
example(neg(przodek2(alicja,edek))).
example(neg(przodek2(alicja,marta))).
example(neg(przodek2(alicja,alicja))).

people([marek,edek,jozek,marta,alicja]).
