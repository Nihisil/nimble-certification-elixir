defmodule GoogleScrapingWeb.Api.V1.UploadKeywordControllerTest do
  use GoogleScrapingWeb.ConnCase, async: true

  describe "post create/2" do
    test "given the valid keywords file, returns 201 status with success message", %{conn: conn} do
      use_cassette "google/valid_file" do
        user = insert(:user)
        upload_file = keyword_file_fixture("valid.csv")

        conn =
          conn
          |> token_auth_user(user)
          |> post(Routes.api_upload_keyword_path(conn, :create), %{
            keyword_csv_file: %{file: upload_file}
          })

        assert %{
                 "data" => %{
                   "attributes" => %{
                     "message" => "Keywords were uploaded!"
                   },
                   "id" => _,
                   "relationships" => %{},
                   "type" => "upload_keyword"
                 },
                 "included" => []
               } = json_response(conn, 201)
      end
    end
  end

  test "given an empty file, returns 400 status with error details", %{conn: conn} do
    user = insert(:user)
    upload_file = keyword_file_fixture("empty.csv")

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{
        keyword_csv_file: %{file: upload_file}
      })

    assert %{"errors" => [%{"detail" => "The file is empty", "status" => "bad_request"}]} ==
             json_response(conn, 400)
  end

  test "given a big file, returns 400 status with error details", %{conn: conn} do
    user = insert(:user)
    upload_file = keyword_file_fixture("big.csv")

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{
        keyword_csv_file: %{file: upload_file}
      })

    assert %{
             "errors" => [
               %{
                 "detail" => "The file is too big, allowed size is up to 1000 keywords",
                 "status" => "bad_request"
               }
             ]
           } ==
             json_response(conn, 400)
  end

  test "given a non valid file, returns 400 status with error details", %{conn: conn} do
    user = insert(:user)
    upload_file = keyword_file_fixture("non_valid.csv")

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{
        keyword_csv_file: %{file: upload_file}
      })

    assert %{
             "errors" => [
               %{
                 "detail" => "One or more keywords are invalid! Allowed keyword length is 1-100",
                 "status" => "bad_request"
               }
             ]
           } ==
             json_response(conn, 400)
  end

  test "given a no file, returns 400 status with error details", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{
        keyword_csv_file: %{file: nil}
      })

    assert %{"errors" => [%{"detail" => "file can't be blank", "status" => "bad_request"}]} ==
             json_response(conn, 400)
  end
end
