# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $newPostTextArea = $('.new_micropost textarea')
  maxLength = parseInt($newPostTextArea.attr('maxlength'), 10)

  $newPostTextArea.on 'keyup', ->
    numRemainingChars =  maxLength - $newPostTextArea.val().length
    characterExpression = if numRemainingChars == 1 then 'character' else 'characters'
    $('.new_micropost .char-remaining').text("#{numRemainingChars} #{characterExpression} remaining")

