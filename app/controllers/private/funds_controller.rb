module Private
  class FundsController < BaseController
    layout 'funds'

    before_action :auth_activated!
    # before_action :auth_verified!
    before_action :two_factor_activated!

    def index
      @notification = Notification.where(active: true).first

      @deposit_channels = DepositChannel.all
      @withdraw_channels = WithdrawChannel.all
      @deposits = current_user.deposits
      @accounts = current_user.accounts.enabled
      @withdraws = current_user.withdraws
      @fund_sources = current_user.fund_sources
      @banks = Bank.all

      gon.jbuilder
    end

    def gen_address
      current_user.accounts.each do |account|
        next if account.currency_obj.nil? || (not account.currency_obj.coin?)

        if account.payment_addresses.blank?
          if not account.id.nil?
            account.payment_addresses.create(currency: account.currency)
          end
        else
          address = account.payment_addresses.last
          address.gen_address if address.address.blank?
        end
      end
      render nothing: true
    end

  end
end

