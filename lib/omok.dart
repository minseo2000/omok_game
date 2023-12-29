class Omok{
  String? omokDate;
  int? win;
  int? tie;
  int? defeat;
  int? downCount;
  int? score;

  Omok({
    this.omokDate,
    this.win,
    this.tie,
    this.defeat,
    this.downCount,
    this.score
});
  Map<String, dynamic> toMap(){
    return {
      'omokDate' : omokDate,
      'win' : win,
      'tie' : tie,
      'defeat' : defeat,
      'downCount' : downCount,
      'score' : score
    };
  }
}