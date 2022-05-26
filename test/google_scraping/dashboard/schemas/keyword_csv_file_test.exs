defmodule GoogleScraping.Dashboard.Schemas.KeywordCSVFileTest do
  use GoogleScraping.DataCase, async: true

  alias GoogleScraping.Dashboard.Schemas.KeywordCSVFile

  describe "create_changeset/1" do
    test "when file exists, returns valid changeset" do
      attrs = %{file: keyword_file_fixture("valid.csv")}

      changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{}, attrs)

      assert changeset.valid? == true
      assert changeset.changes == attrs
    end

    test "when file is not CSV type, returns invalid changeset" do
      attrs = %{file: keyword_file_fixture("non_csv.txt")}

      changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{}, attrs)

      assert changeset.valid? == false
      assert errors_on(changeset) == %{file: ["file is not valid CSV"]}
    end

    test "when file doesn't exist, returns invalid changeset" do
      changeset = KeywordCSVFile.create_changeset(%KeywordCSVFile{}, %{file: nil})

      assert changeset.valid? == false
      assert errors_on(changeset) == %{file: ["can't be blank"]}
    end
  end

  describe "parse/1" do
    test "given valid keywords file, returns the keywords list" do
      %{path: file_path} = keyword_file_fixture("valid.csv")

      assert KeywordCSVFile.parse(file_path) == {:ok, ["one", "two", "three"]}
    end

    test "given an empty keywords file, returns error" do
      %{path: file_path} = keyword_file_fixture("empty.csv")

      assert KeywordCSVFile.parse(file_path) == {:error, :empty_file_error}
    end

    test "given an big keywords file, returns error" do
      %{path: file_path} = keyword_file_fixture("big.csv")

      assert KeywordCSVFile.parse(file_path) == {:error, :file_is_too_long_error}
    end

    test "given an file with invalid keywords, returns error" do
      %{path: file_path} = keyword_file_fixture("non_valid.csv")

      assert KeywordCSVFile.parse(file_path) == {:error, :one_or_more_keywords_are_invalid}
    end

    test "given an file with invalid keywords, returns error" do
      %{path: file_path} = keyword_file_fixture("non_valid.csv")

      assert {:error, :one_or_more_keywords_are_invalid} = KeywordCSVFile.parse(file_path)
    end
  end
end
