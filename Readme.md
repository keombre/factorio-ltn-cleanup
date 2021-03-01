# LTN Cleanup


## About
Automatically sends LTN trains with remaining cargo to a cleanup stop.

This mod doesn't add any new stops, instead, it uses the new rich text feature in stop names.

## Usage
Firstly you will need to mark your cleanup stops (see Stop naming section on how).
While you're at it you can (and probably should) also specify what is that stop capable of cleaning.
You can specify any item or fluid, or you can use a special signal to describe all items.
Please note, that the cleanup stop doesn't have to be an LTN stop, vanilla stops with a correct name work just fine.

After that the setup is complete.
Now if any train leaves request stop with remaining cargo, the Cleanup dispatcher will plan a route to remove all items and fluids. Note, that it tries to use the wildcard stop as the last resort.

If there are no train stops capable of clearing the cargo, the dispatcher will simply send the train to the depot.

### Stop naming
The syntax is very loose. You can have text between the rich text symbols and the symbols don't need to be in any specific order.

 - Any train stop containing the signal ![](https://raw.githubusercontent.com/keombre/factorio-ltn-cleanup/master/signal_cleanup_32x32.png) "LTN Cleanup stop" in its name will be marked as a cleanup stop.
 - Any other rich text symbol (item or fluid) in the name will mark that stop as capable of clearing that specific item or fluid.
 - You can have as many markers as you want.
 - Any stop marked with the signal ![](https://github.com/keombre/factorio-ltn-cleanup/blob/master/signal_item_cleanup_32x32.png?raw=true)"LTN Item cleanup" will accept any item.

Please note, that there is no wildcard stop for fluids. This is intentional since fluids cannot mix in pipes.

Also note, that if you have multiple wildcard cleanup stops, that have a different name, the dispatcher will choose one at random.

### Sample stop names
An example is worth a thousand words

 - **All items:** ![](https://raw.githubusercontent.com/keombre/factorio-ltn-cleanup/master/signal_cleanup_32x32.png)![](https://github.com/keombre/factorio-ltn-cleanup/blob/master/signal_item_cleanup_32x32.png?raw=true)
   - `[virtual-signal=ltn-cleanup-station][virtual-signal=ltn-item-cleanup-station]`
 - **Basic vanilla fluids:** ![](https://raw.githubusercontent.com/keombre/factorio-ltn-cleanup/master/signal_cleanup_32x32.png)![](https://wiki.factorio.com/images/thumb/Water.png/32px-Water.png)![](https://wiki.factorio.com/images/thumb/Steam.png/32px-Steam.png)
   * `[virtual-signal=ltn-cleanup-station][fluid=water][fluid=steam]`
 - **Some vanilla burnables:** ![](https://raw.githubusercontent.com/keombre/factorio-ltn-cleanup/master/signal_cleanup_32x32.png)![](https://wiki.factorio.com/images/thumb/Wood.png/32px-Wood.png)![](https://wiki.factorio.com/images/thumb/Coal.png/32px-Coal.png)
   * `[virtual-signal=ltn-cleanup-station][item=wood][item=coal]`
 - **Or something crazy:** This stop ![](https://raw.githubusercontent.com/keombre/factorio-ltn-cleanup/master/signal_cleanup_32x32.png) can process ![](https://wiki.factorio.com/images/thumb/Water.png/32px-Water.png), ![](https://wiki.factorio.com/images/thumb/Wooden_chest.png/32px-Wooden_chest.png) but not iron
   * `This stop [virtual-signal=ltn-cleanup-station] can process [fluid=water], [item=wooden-chest], but not iron`

Of course, you don't need to write it by hand, Factorio has a rich text editor built right in.

### Automated fluid stop generation

If you can't be bothered to set up your fluid void stops (as I couldn't) have a look at this little project: https://github.com/keombre/factorio-ltn-cleanup-station-gen

Currently, it generates stops only for pyanodons, but adding support for other modpacks shouldn't be that difficult.

## Credits
Thanks to Optera for allowing me to use the LTN thumbnail and for support with the Factorio API.
