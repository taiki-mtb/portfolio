require 'rails_helper'

RSpec.describe "Restaurants", type: :system do
  let!(:admin_user) { create(:user, :admin) }
  let!(:user)       { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:restaurant) { create(:restaurant, :picture) }
  let!(:comment)    { create(:comment) }
  let!(:category)   { create(:category) }

  describe "レストラン登録ページ" do
    before do
      login_for_system(admin_user)
      visit new_restaurant_path
    end

    context "ページレイアウト" do
      it "「レストラン登録」の文字列が存在すること" do
        expect(page).to have_content 'レストラン登録'
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('レストラン登録')
      end

      it "入力部分に適切なラベルが表示されること" do
        expect(page).to have_content '名前'
        expect(page).to have_content '説明'
        expect(page).to have_content 'カテゴリー'
        expect(page).to have_content '写真'
        expect(page).to have_content '住所'
        expect(page).to have_content '地図'
      end
    end

    context "レストラン登録処理" do
      it "有効な情報で登録を行うと登録成功のフラッシュが表示されること" do
        fill_in "名前", with: "レストラン"
        fill_in "説明", with: "冬に行きたい、身体が温まるレストランです"
        select "居酒屋", from: "category_id"
        attach_file "restaurant[picture]", "#{Rails.root}/spec/fixtures/test_restaurant.jpg"
        click_button "登録する"
        expect(page).to have_content "レストランが登録されました！"
      end

      #  it "画像無しで登録すると、デフォルト画像が割り当てられること" do
      #    fill_in "名前", with: "レストラン"
      #    click_button "登録する"
      #    expect(page).to have_selector("img[src*='assets/default']")
      #  end

      it "無効な情報で登録を行うと登録失敗のフラッシュが表示されること" do
        fill_in "名前", with: ""
        fill_in "説明", with: "冬に行きたい、身体が温まるレストランです"
        click_button "登録する"
        expect(page).to have_content "名前を入力してください"
      end
    end
  end

  describe "レストラン詳細ページ" do
    context "ページレイアウト" do
      before do
        visit restaurant_path(restaurant)
      end

      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title("#{restaurant.name}")
      end

      it "レストラン情報が表示されること" do
        expect(page).to have_content restaurant.name
        expect(page).to have_content restaurant.description
        expect(page).to have_link href: restaurant_path(restaurant), class: 'restaurant-picture'
      end
    end
  end

  describe "レストラン編集ページ" do
    before do
      login_for_system(admin_user)
      visit restaurant_path(restaurant)
      click_link "編集"
    end

    context "ページレイアウト" do
      it "正しいタイトルが表示されること" do
        expect(page).to have_title full_title('レストラン情報の編集')
      end

      it "入力部分に適切なラベルが表示されること" do
        expect(page).to have_content '名前'
        expect(page).to have_content '説明'
        expect(page).to have_content '写真'
        expect(page).to have_content 'カテゴリー'
        expect(page).to have_content '住所'
        expect(page).to have_content '地図'
      end
    end

    # context "レストランの削除処理", js: true do
    #   it "削除成功のフラッシュが表示されること" do
    #     click_on '削除'
    #     page.driver.browser.switch_to.alert.accept
    #     expect(page).to have_content '料理が削除されました'
    #   end
    # end

    context "レストランの更新処理" do
      # it "有効な更新" do
      #  fill_in "名前", with: "編集：レストラン2"
      #  fill_in "説明", with: "編集：冬に行きたい、身体が温まるレストランです"
      #  select "居酒屋", from: "category_id"
      #  attach_file "restaurant[picture]", "#{Rails.root}/spec/fixtures/test_restaurant2.jpg"
      #  click_button "更新する"
      #  expect(page).to have_content "レストラン情報が更新されました！"
      #  expect(restaurant.reload.name).to eq "編集：レストラン2"
      #  expect(restaurant.reload.description).to eq "編集：冬に行きたい、身体が温まるレストランです"
      #  expect(restaurant.reload.picture.url).to include "test_restaurant2.jpg"
      # end

      it "無効な更新" do
        fill_in "名前", with: ""
        click_button "更新する"
        expect(page).to have_content '名前を入力してください'
        expect(restaurant.reload.name).not_to eq ""
      end
    end

    context "コメントの登録＆削除" do
      before do
        login_for_system(user)
        visit restaurant_path(restaurant)
        fill_in "comment_content", with: "料理も店員さんも最高でした。"
        click_button "コメント"
      end

      it "レストランに対するコメントの登録＆削除が正常に完了すること" do
        within find("#comment-#{Comment.last.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: '料理も店員さんも最高でした。'
        end
        expect(page).to have_content "コメントを追加しました！"
        click_link "削除", href: comment_path(Comment.last)
        expect(page).not_to have_selector 'span', text: '料理も店員さんも最高でした。'
        expect(page).to have_content "コメントを削除しました"
      end

      it "別ユーザーのコメントには削除リンクが無いこと" do
        login_for_system(other_user)
        visit restaurant_path(restaurant)
        within find("#comment-#{Comment.last.id}") do
          expect(page).to have_selector 'span', text: user.name
          expect(page).to have_selector 'span', text: comment.content
          expect(page).not_to have_link '削除', href: restaurant_path(restaurant)
        end
      end
    end
  end
end
