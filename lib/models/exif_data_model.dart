class EXIFDataModel {
  const EXIFDataModel({this.category, this.comment, this.filename, this.sequence, this.specimen, this.subcategory, this.surveyInfo});

  final String surveyInfo;
  final String filename;
  final String category;
  final String subcategory;
  final String specimen;
  final String sequence;
  final String comment;
}
