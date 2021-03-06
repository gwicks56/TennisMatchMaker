class MatchesController < ApplicationController
  before_action :authenticate_user
  before_action :set_match, only: [:show, :edit, :update, :destroy, :join, :kick]
  before_action :host, only: [:edit, :update, :destroy, :kick]
  include MatchesHelper

  # GET /matches
  # GET /matches.json
  def find_matches
    @match_distances = Match.find_match(current_user, "Any", nil)
  end

  # the controller for partial view of carousel which is appended on find_matches.html.erb via ajax
  def carousel
    @match_distances = Match.find_match(current_user, params[:match_type], params[:after].to_date)
    render :partial => 'carousel', :content_type => 'text/html', :locals => {:match_distances => @match_distances}
  end


  # GET /matches/1
  # GET /matches/1.json
  def show
    @conversation = Conversation.find_by_id(@match.conversation_id)
    @messages = @conversation.messages
    @message = Message.new
  end

  # GET /matches
  def index
    @up_matches = Match.upcoming_matches(current_user.id)
    @prev_matches = Match.previous_matches(current_user.id)
  end

  # GET /matches/new
  def new
    @match = Match.new
    # Default values entered for new match.
    #   Postcode is defaulted to user's postcode.
    #   Hours duration is defaulted to 2 hours.
    @match.postcode = current_user.postcode
    @match.duration_hours = 2
  end

  # GET /matches/1/edit
  def edit
  end

  # POST /matches
  # POST /matches.json
  def create
    @match = Match.new(match_params)
    @match.player1_id = current_user.id
    @match.end = @match.end_date

    # Create a conversation for match.
    conv = Conversation.new
    conv.match_id = @match.id
    conv.save!

    @match.conversation_id = conv.id
    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: ['Match was successfully created.', "alert alert-dismissible alert-success"] }
      else
        format.html { render action: 'new' }
      end
    end
  end

  # PATCH/PUT /matches/1
  # PATCH/PUT /matches/1.json
  def update
    @match.assign_attributes(match_params)
    @match.end = @match.end_date
    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: ['Match was successfully updated.', "alert alert-dismissible alert-success"] }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # join or leave match
  def join
    pids = get_player_list(@match).map{|p| p.try(:id)} # list of player ids
    status = false
    if can_join(pids) #if possible, join
      status = join_now(@match, current_user.id)
      done = ["joined", "success"]
    elsif pids.include?(current_user.id) #if already joined, then leave
      status = leave_now(@match, current_user.id, @host)
      done = ["left", "warning"]
      if !get_player_list(@match).any? #if there is no more players in match, then destroy
        destroy
        return
      end
    end

    respond_to do |format|
      if status and @match.save
        format.html { redirect_to @match, notice: ['You have succesfully ' + done[0] + ' the match.', "alert alert-dismissible alert-" + done[1]] }
      else
        format.html { redirect_to @match, notice: ['Sorry, your request could not be processed.', "alert alert-dismissible alert-danger"] }
      end
    end
  end

  # host can kick people out of match
  def kick
    status = false
    pid = params[:match][:pid].to_i
    # find and kick player out by setting foreign key to nil
    if (@match.player2_id == pid) then @match.player2_id = nil; status = true
    elsif (@match.player3_id == pid) then @match.player3_id = nil; status = true
    elsif (@match.player4_id == pid) then @match.player4_id = nil; status = true
    end

    respond_to do |format|
      if status and @match.save
        format.html { redirect_to @match, notice: ['Player have been successfully kicked out.', "alert alert-dismissible alert-success" ] }
      else
        format.html { redirect_to @match, notice: ['Sorry, your request could not be processed.', "alert alert-dismissible alert-danger"] }
      end
    end
  end

  # DELETE /matches/1
  # DELETE /matches/1.json
  def destroy
   @match.destroy

    respond_to do |format|
      format.html { redirect_to @match, notice: ['You have succesfully left the match.', "alert alert-dismissible alert-warning"]}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
      @host = false
      if current_user and current_user.id == @match.player1_id
        @host = true
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def match_params
      params.require(:match).permit(:start, :duration_hours, :duration_days, :court, :desc, :match_type, :pid, :country, :postcode, :after)
    end

    def host
      if (!current_user or current_user.id != @match.player1_id)
        redirect_to root_path
      end
    end
end
