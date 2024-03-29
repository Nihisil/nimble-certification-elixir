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
            keyword_csv_file: upload_file
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

  test "given an empty file, returns 422 status with error details", %{conn: conn} do
    user = insert(:user)
    upload_file = keyword_file_fixture("empty.csv")

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{
        keyword_csv_file: upload_file
      })

    assert json_response(conn, 422) == %{
             "errors" => [%{"detail" => "The file is empty", "status" => "unprocessable_entity"}]
           }
  end

  test "given a big file, returns 422 status with error details", %{conn: conn} do
    user = insert(:user)
    upload_file = keyword_file_fixture("big.csv")

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{
        keyword_csv_file: upload_file
      })

    assert json_response(conn, 422) == %{
             "errors" => [
               %{
                 "detail" => "The file is too big, allowed size is up to 1000 keywords",
                 "status" => "unprocessable_entity"
               }
             ]
           }
  end

  test "given a NON valid file, returns 422 status with error details", %{conn: conn} do
    user = insert(:user)
    upload_file = keyword_file_fixture("non_valid.csv")

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{
        keyword_csv_file: upload_file
      })

    assert json_response(conn, 422) == %{
             "errors" => [
               %{
                 "detail" => "One or more keywords are invalid! Allowed keyword length is 1-100",
                 "status" => "unprocessable_entity"
               }
             ]
           }
  end

  test "given a no file, returns 422 status with error details", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{
        keyword_csv_file: nil
      })

    assert json_response(conn, 422) == %{
             "errors" => [%{"detail" => "file can't be blank", "status" => "unprocessable_entity"}]
           }
  end

  test "given a no file attribute, returns 422 status with error details", %{conn: conn} do
    user = insert(:user)

    conn =
      conn
      |> token_auth_user(user)
      |> post(Routes.api_upload_keyword_path(conn, :create), %{})

    assert json_response(conn, 422) == %{
             "errors" => [
               %{
                 "detail" => "Invalid input attributes. Add `keyword_csv_file` to request body",
                 "status" => "unprocessable_entity"
               }
             ]
           }
  end
end
