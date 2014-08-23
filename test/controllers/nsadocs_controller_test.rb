require 'test_helper'

class NsadocsControllerTest < ActionController::TestCase
  setup do
    @nsadoc = nsadocs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:nsadocs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create nsadoc" do
    assert_difference('Nsadoc.count') do
      post :create, nsadoc: { aclu_desc: @nsadoc.aclu_desc, article_url: @nsadoc.article_url, codewords: @nsadoc.codewords, countries: @nsadoc.countries, creation_date: @nsadoc.creation_date, doc_path: @nsadoc.doc_path, doc_text: @nsadoc.doc_text, legal_authority: @nsadoc.legal_authority, programs: @nsadoc.programs, records_collected: @nsadoc.records_collected, release_date: @nsadoc.release_date, released_by: @nsadoc.released_by, sigads: @nsadoc.sigads, title: @nsadoc.title, type: @nsadoc.type }
    end

    assert_redirected_to nsadoc_path(assigns(:nsadoc))
  end

  test "should show nsadoc" do
    get :show, id: @nsadoc
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @nsadoc
    assert_response :success
  end

  test "should update nsadoc" do
    patch :update, id: @nsadoc, nsadoc: { aclu_desc: @nsadoc.aclu_desc, article_url: @nsadoc.article_url, codewords: @nsadoc.codewords, countries: @nsadoc.countries, creation_date: @nsadoc.creation_date, doc_path: @nsadoc.doc_path, doc_text: @nsadoc.doc_text, legal_authority: @nsadoc.legal_authority, programs: @nsadoc.programs, records_collected: @nsadoc.records_collected, release_date: @nsadoc.release_date, released_by: @nsadoc.released_by, sigads: @nsadoc.sigads, title: @nsadoc.title, type: @nsadoc.type }
    assert_redirected_to nsadoc_path(assigns(:nsadoc))
  end

  test "should destroy nsadoc" do
    assert_difference('Nsadoc.count', -1) do
      delete :destroy, id: @nsadoc
    end

    assert_redirected_to nsadocs_path
  end
end
