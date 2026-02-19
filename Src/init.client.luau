print('loading')
wax.shared.EverloseStartTime = tick()

print(wax)
for i,v in wax.script do
    print(i,v)
end
print('--------------')
warn('loaded!')