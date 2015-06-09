require 'test_helper'

class DocsControllerTest < ActionController::TestCase
  setup do
    @doc = docs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:docs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create doc" do
    assert_difference('Doc.count') do
      post :create, doc: { aclu_desc: @doc.aclu_desc, article_url: @doc.article_url, codewords: @doc.codewords, countries: @doc.countries, creation_date: @doc.creation_date, doc_path: @doc.doc_path, doc_text: @doc.doc_text, legal_authority: @doc.legal_authority, programs: @doc.programs, records_collected: @doc.records_collected, release_date: @doc.release_date, released_by: @doc.released_by, sigads: @doc.sigads, title: @doc.title, type: @doc.type }
    end

    assert_redirected_to doc_path(assigns(:doc))
  end

  test "should show doc" do
    get :show, id: @doc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @doc
    assert_response :success
  end

  test "should update doc" do
    patch :update, id: @doc, doc: { aclu_desc: @doc.aclu_desc, article_url: @doc.article_url, codewords: @doc.codewords, countries: @doc.countries, creation_date: @doc.creation_date, doc_path: @doc.doc_path, doc_text: @doc.doc_text, legal_authority: @doc.legal_authority, programs: @doc.programs, records_collected: @doc.records_collected, release_date: @doc.release_date, released_by: @doc.released_by, sigads: @doc.sigads, title: @doc.title, type: @doc.type }
    assert_redirected_to doc_path(assigns(:doc))
  end

  test "should destroy doc" do
    assert_difference('Doc.count', -1) do
      delete :destroy, id: @doc
    end

    assert_redirected_to docs_path
  end
end
