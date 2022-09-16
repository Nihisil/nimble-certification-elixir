defmodule GoogleScrapingWeb.KeywordControllerTest do
  use GoogleScrapingWeb.ConnCase

  describe "GET index/2" do
    test "when given auth user, renders list of keywords page", %{conn: conn} do
      user = insert(:user)
      conn = conn |> log_in_user(user) |> get(Routes.keyword_path(conn, :index))

      assert html_response(conn, 200) =~ "Keywords"
    end

    test "when given NOT auth user, redirects to login page", %{conn: conn} do
      conn = get(conn, Routes.keyword_path(conn, :index))

      assert html_response(conn, 302) =~ "/log_in"
    end
  end

  describe "POST create/2" do
    test "given valid file, creates keywords", %{conn: conn} do
      use_cassette "google/valid_file" do
        user = insert(:user)
        upload_file = keyword_file_fixture("valid.csv")

        conn =
          conn
          |> log_in_user(user)
          |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

        assert get_flash(conn, :info) == "Keywords were uploaded!"
      end
    end

    test "given empty file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("empty.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil
      assert get_flash(conn, :error) == "The file is empty."
    end

    test "given big file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("big.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil
      assert get_flash(conn, :error) == "The file is too big, allowed size is up to 1000 keywords"
    end

    test "given non CSV file, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("non_csv.txt")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil
      assert get_flash(conn, :error) == "The file doesn't look like CSV."
    end

    test "given file with invalid keywords, shows validation error", %{conn: conn} do
      user = insert(:user)
      upload_file = keyword_file_fixture("non_valid.csv")

      conn =
        conn
        |> log_in_user(user)
        |> post(Routes.keyword_path(conn, :create), %{keyword_csv_file: %{file: upload_file}})

      assert get_flash(conn, :info) == nil

      assert get_flash(conn, :error) ==
               "One or more keywords are invalid! Allowed keyword length is 1-100"
    end
  end

  describe "GET show/2" do
    test "when given auth user and keyword, renders keywords details page", %{conn: conn} do
      user = insert(:user)

      keyword =
        insert(:keyword,
          user_id: user.id,
          name: "test keyword",
          status: :completed,
          ad_total_count: 100
        )

      conn = conn |> log_in_user(user) |> get(Routes.keyword_path(conn, :show, keyword))
      response = html_response(conn, 200)

      assert response =~ keyword.name
      assert response =~ "#{keyword.ad_total_count}"
    end

    test "when given NOT auth user, redirects to login page", %{conn: conn} do
      keyword = insert(:keyword)
      conn = get(conn, Routes.keyword_path(conn, :show, keyword))

      assert html_response(conn, 302) =~ "/log_in"
    end

    test "when given another user keyword, shows not found error", %{conn: conn} do
      another_user = insert(:user)
      keyword = insert(:keyword, user_id: another_user.id)

      assert_raise Ecto.NoResultsError, fn ->
        user = insert(:user)
        conn |> log_in_user(user) |> get(Routes.keyword_path(conn, :show, keyword))
      end
    end
  end
end
